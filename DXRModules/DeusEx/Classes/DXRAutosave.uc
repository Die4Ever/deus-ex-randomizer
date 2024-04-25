#compileif injections
class DXRAutosave extends DXRActorsBase transient;

var transient bool bNeedSave;
var config float save_delay;
var transient float save_timer;
var transient int autosave_combat;

var vector player_pos;
var rotator player_rot;
var bool set_player_pos;
var float old_game_speed;

const Disabled = 0;
const FirstEntry = 1;
const EveryEntry = 2;
const Hardcore = 3;// same as FirstEntry but without manual saving
const ExtraSafe = 4;
const Ironman = 5; // never autosaves, TODO: maybe some fancy logic to autosave on quit and autodelete on load?

function CheckConfig()
{
    if( ConfigOlderThan(2,5,2,9) ) {
        save_delay = 0.1;
    }
    Super.CheckConfig();
    autosave_combat = class'MenuChoice_AutosaveCombat'.default.value;
}

function BeginPlay()
{
    Super.BeginPlay();
    Disable('Tick');
}

function PreFirstEntry()
{
    Super.PreFirstEntry();
    l("PreFirstEntry() " $ dxr.dxInfo.MissionNumber);
    if( dxr.dxInfo != None && dxr.dxInfo.MissionNumber > 0 && dxr.dxInfo.MissionNumber < 98 ) {
        if(dxr.flags.autosave > 0 && dxr.flags.autosave != Ironman) {
            NeedSave();
        }
    }
}

function ReEntry(bool IsTravel)
{
    Super.ReEntry(IsTravel);
    l("ReEntry() " $ dxr.dxInfo.MissionNumber);
    if( dxr.dxInfo != None && dxr.dxInfo.MissionNumber > 0 && dxr.dxInfo.MissionNumber < 98 && IsTravel ) {
        if( dxr.flags.autosave==EveryEntry || dxr.flags.autosave==ExtraSafe ) {
            NeedSave();
        }
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
    if(old_game_speed==0) {
        old_game_speed = Level.Game.GameSpeed;
    }
    if(autosave_combat>0 || !PawnIsInCombat(player())) {
        autosave_combat = 1;// we're all in on this autosave because of the player rotation
        if(!set_player_pos) {
            set_player_pos = true;
            class'DynamicTeleporter'.static.CheckTeleport(player(), coords_mult);
            player_pos = player().Location;
            player_rot = player().ViewRotation;
        }
        SetGameSpeed(0);
    }
}

function SetGameSpeed(float s)
{
    local MissionScript mission;
    local int i;

    s = FMax(s, 0.01);// ServerSetSloMo only goes down to 0.1
    if(s == Level.Game.GameSpeed) return;
    l("SetGameSpeed " @ s);
    Level.Game.GameSpeed = s;
    Level.TimeDilation = s;
    Level.Game.SetTimer(s, true);
    if(s == 1) {
        Level.Game.SaveConfig();
        Level.Game.GameReplicationInfo.SaveConfig();
    }

    // we need the mission script to clear PlayerTraveling
    if(s <= 0.1) s /= 2;// might as well run the timer faster?
    foreach AllActors(class'MissionScript', mission) {
        mission.SetTimer(mission.checkTime * s, true);
        i++;
    }
    // if no mission script found, clean up the traveling flag
    if(i==0 && dxr.flagbase.GetBool('PlayerTraveling')) {
        info("no missionscript found in " $ dxr.localURL);
        dxr.flagbase.SetBool('PlayerTraveling', false);
    }
}

function FixPlayer(optional bool pos)
{
    local #var(PlayerPawn) p;

    if(set_player_pos) {
        p=player();
        if(pos) {
            p.SetLocation(player_pos - vect(0,0,16));// a foot lower so you don't raise up
            p.PutCarriedDecorationInHand();
        }
        p.ViewRotation = player_rot;
        p.Velocity = vect(0,0,0);
        p.Acceleration = vect(0,0,0);
    }
}

function Tick(float delta)
{
    delta /= Level.Game.GameSpeed;
    delta = FClamp(delta, 0.01, 0.05);// a single slow frame should not expire the timer by itself
    save_timer -= delta;
    FixPlayer();
    if(bNeedSave) {
        if(save_timer <= 0) {
            doAutosave();
        }
    }
    else if(save_timer <= 0) {
        if(Level.Game.GameSpeed == 1)// TODO: figure out what's wrong with using old_game_speed instead of 1
            Disable('Tick');
        FixPlayer(Level.Game.GameSpeed == 1);
        SetGameSpeed(1);
    } else {
        SetGameSpeed(0);
    }
}

static function bool AllowManualSaves(DeusExPlayer player)
{
    local DXRFlags f;
    f = Human(player).GetDXR().flags;
    if( f == None ) return true;
    if( f.autosave == Hardcore || f.autosave == Ironman ) return false;

    if(player.dataLinkPlay != None) {
        player.dataLinkPlay.FastForward();
    }

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

    if(autosave_combat<=0 && PawnIsInCombat(p)) {
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
    SetGameSpeed(1);// TODO: figure out what's wrong with using old_game_speed instead of 1
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
