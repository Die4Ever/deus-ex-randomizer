class DXRAutosave extends DXRActorsBase transient;

var transient bool bNeedSave;
var config float save_delay;
var transient float save_timer;

const Disabled = 0;
const FirstEntry = 1;
const EveryEntry = 2;
const Hardcore = 3;
const ExtraSafe = 4;

function CheckConfig()
{
    if( ConfigOlderThan(2,5,2,7) ) {
        save_delay = 0.5;
    }
    Super.CheckConfig();
    Disable('Tick');
}

function PreFirstEntry()
{
    Super.PreFirstEntry();
    l("PreFirstEntry() " $ dxr.dxInfo.MissionNumber);
    if( dxr.dxInfo != None && dxr.dxInfo.MissionNumber > 0 && dxr.dxInfo.MissionNumber < 98 && dxr.flags.autosave > 0 ) {
        NeedSave();
    }
}

function ReEntry(bool IsTravel)
{
    Super.ReEntry(IsTravel);
    l("ReEntry() " $ dxr.dxInfo.MissionNumber);
    if( dxr.dxInfo != None && dxr.dxInfo.MissionNumber > 0 && dxr.dxInfo.MissionNumber < 98 && dxr.flags.autosave>=EveryEntry && dxr.flags.autosave != Hardcore && IsTravel ) {
        NeedSave();
    }
}

function PostAnyEntry()
{
    if(bNeedSave)
        NeedSave();
}

function NeedSave()
{
    bNeedSave = true;
    save_timer = save_delay;
    Enable('Tick');
    if(!PawnIsInCombat(player()))
        SetGameSpeed(0);
}

function SetGameSpeed(float s)
{
    local MissionScript mission;

    s = FMax(s, 0.01);// ServerSetSloMo only goes down to 0.1
    if(s == Level.Game.GameSpeed) return;
    Level.Game.GameSpeed = s;
    Level.TimeDilation = s;
    Level.Game.SetTimer(s, true);
    Level.Game.SaveConfig();
    Level.Game.GameReplicationInfo.SaveConfig();

    // we need the mission script to clear PlayerTraveling
    if(s < 0.5) s /= 2;// might as well run the timer faster?
    foreach AllActors(class'MissionScript', mission) {
        mission.SetTimer(mission.checkTime * s, true);
    }
}

function Tick(float delta)
{
    if(bNeedSave) {
        save_timer -= delta / Level.Game.GameSpeed;
        if(save_timer <= 0) {
            doAutosave();
        }
    }
    else if(save_timer <= 0) {
        SetGameSpeed(1);
        Disable('Tick');
    } else {
        save_timer -= delta / Level.Game.GameSpeed;
        SetGameSpeed(0.2);
    }
}

static function bool AllowManualSaves(DeusExPlayer player)
{
    local DXRFlags f;
    f = Human(player).GetDXR().flags;
    if( f == None ) return true;
    if( f.autosave == Hardcore ) return false;
    if( f.IsHordeMode() ) return false;
    return true;
}

function doAutosave()
{
    local string saveName;
    local DataLinkPlay interruptedDL;
    local #var(PlayerPawn) p;
    local int saveSlot;
    local int lastMission;
    local bool isDifferentMission;

    save_timer = save_delay;

    if( dxr == None ) {
        info("dxr == None, doAutosave() not saving yet");
        return;
    }

    if( dxr.bTickEnabled ) {
        info("dxr.bTickEnabled, doAutosave() not saving yet");
        return;
    }
    if( dxr.flagbase.GetBool('PlayerTraveling') ) {
        info("waiting for PlayerTraveling to be cleared by the MissionScript, not saving yet");
        return;
    }

    p = player();

    if(PawnIsInCombat(p)) {
        info("waiting for Player to be out of combat, not saving yet");
        SetGameSpeed(1);
        return;
    }

    //copied from DeusExPlayer QuickSave()
    if (
        (dxr.dxInfo == None) || (dxr.dxInfo.MissionNumber < 0) ||
        ((p.IsInState('Dying')) || (p.IsInState('Paralyzed')) || (p.IsInState('Interpolating'))) ||
        /*(p.dataLinkPlay != None) ||*/ (dxr.Level.Netmode != NM_Standalone) || (p.InConversation())
    ){
        info("doAutosave() not saving yet");
        return;
    }

    if( p.dataLinkPlay != None ) {
        p.dataLinkPlay.AbortDataLink();
        interruptedDL = p.dataLinkPlay;
        p.dataLinkPlay = None;
    }

    saveSlot = -3;
    saveName = "DXR " $ dxr.seed $ ": " $ dxr.dxInfo.MissionLocation;
    lastMission = dxr.flags.f.GetInt('Rando_lastmission');

    isDifferentMission = lastMission != 0 && dxr.dxInfo.MissionNumber != 0 && lastMission != dxr.dxInfo.MissionNumber;
    if( isDifferentMission || dxr.flags.autosave == ExtraSafe ) {
        saveSlot = 0;
        saveName = "DXR " $ dxr.seed $ ", Mission " $ dxr.dxInfo.MissionNumber $ ": " $ dxr.dxInfo.MissionLocation;
    }
    dxr.flags.f.SetInt('Rando_lastmission', dxr.dxInfo.MissionNumber,, 999);

    info("doAutosave() " $ lastMission @ dxr.dxInfo.MissionNumber @ saveSlot @ saveName @ p.GetStateName() @ save_delay);
    bNeedSave = false;
    SetGameSpeed(1);
    class'DXRStats'.static.IncDataStorageStat(p, "DXRStats_autosaves");
    p.SaveGame(saveSlot, saveName);
    SetGameSpeed(0);

    if( interruptedDL != None ) {
        p.dataLinkPlay = interruptedDL;
        if( interruptedDL.tag != 'dummydatalink' ) {
#ifdef injections
            interruptedDL.restarting = true;
#endif
            interruptedDL.ResumeDataLinks();
        }
    }

    info("doAutosave() completed, save_delay: "$save_delay);
}
