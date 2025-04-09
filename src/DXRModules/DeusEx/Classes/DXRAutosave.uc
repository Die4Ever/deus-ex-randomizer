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
const LimitedSaves = 6; // need an item to save
const FixedSaves = 7; // can only save at computers, AND need an item
const UnlimitedFixedSaves = 8; // need computer, but no item
const FixedSavesExtreme = 9; // can only save at computers, and need TWO MCUs

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
        if(dxr.flags.autosave > 0 && dxr.flags.autosave < Ironman) {
            NeedSave();
        }
        else if((IsFixedSaves() || IsLimitedSaves()) && dxr.flagbase.GetInt('Rando_lastmission')==0)
        {
            // save at the start
            NeedSave();
        }
    }

    MapAdjustments();
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
    local MemConUnit mcu;

    if(bNeedSave)
        NeedSave();

    foreach AllActors(class'MemConUnit', mcu) {
        mcu.PostPostBeginPlay();
    }
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
        Level.LevelAction = LEVACT_Saving;
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
        /*if(pos) {
            p.SetLocation(player_pos - vect(0,0,16));// a foot lower so you don't raise up
            p.PutCarriedDecorationInHand();
        }*/
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
        if(Level.Game.GameSpeed == 1) {// TODO: figure out what's wrong with using old_game_speed instead of 1
            Disable('Tick');
            Level.LevelAction = LEVACT_None;
        }
        FixPlayer(Level.Game.GameSpeed == 1);
        SetGameSpeed(1);
    } else {
        SetGameSpeed(0);
    }
}

static function string GetSaveFailReason(DeusExPlayer player)
{
    local DXRFlags f;
    local DXRAutosave m;
    local DeusExPickup item;

    m = DXRAutosave(class'DXRAutosave'.static.Find());
    if( m == None ) return "";
    f = m.dxr.flags;

    if( f.autosave == Hardcore || f.autosave == Ironman ) {
        return "Manual saving is not allowed in this game mode!  Good Luck!";
    }

    if( f.autosave == FixedSavesExtreme ) {
        item = DeusExPickup(player.FindInventoryType(class'MemConUnit'));
        if(item == None || item.NumCopies <= 1) {
            return "You need 2 Memory Containment Units to save!  Good Luck!";
        }
    }
    else if( m.IsLimitedSaves() ) {
        item = DeusExPickup(player.FindInventoryType(class'MemConUnit'));
        if(item == None || item.NumCopies <= 0) {
            return "You need a Memory Containment Unit to save!  Good Luck!";
        }
    }
    if( m.IsFixedSaves() ) {
        if(Computers(player.FrobTarget) == None && ATM(player.FrobTarget) == None) {
            return "Saving is only allowed when a computer is highlighted!  Good Luck!";
        }
    }

    return "";
}

static function bool CanSaveDuringInfolinks(DeusExPlayer player)
{
    local DXRFlags f;
    f = Human(player).GetDXR().flags;
    if( f == None ) return false;

    return class'MenuChoice_SaveDuringInfolinks'.static.IsEnabled(f);
}

static function SkipInfolinksForSave(DeusExPlayer player)
{
    local DXRFlags f;
    f = Human(player).GetDXR().flags;
    if( f == None ) return;

    if(player.dataLinkPlay != None && class'MenuChoice_SaveDuringInfolinks'.static.IsEnabled(f)) {
        player.dataLinkPlay.FastForward();
    }
}

static function bool AllowManualSaves(DeusExPlayer player, optional bool checkOnly)
{
    local string reason;

    reason = GetSaveFailReason(player);

    if (reason!=""){
        if (!checkOnly){
            player.ClientMessage(reason,, true);
        }
        return false;
    }

    if(!checkOnly) {
        SkipInfolinksForSave(player);
    }

    return true;
}


static function UseSaveItem(DeusExPlayer player)
{
    local DXRAutosave m;
    local DeusExPickup item;

    m = DXRAutosave(class'DXRAutosave'.static.Find());
    if( m == None ) return;

    if( !m.IsLimitedSaves() ) return;

    item = DeusExPickup(player.FindInventoryType(class'MemConUnit'));
    if(item == None) return;

    if(m.dxr.flags.autosave == FixedSavesExtreme) {
        player.ClientMessage("You used 2 " $ item.ItemName $ "s to save.");
        item.UseOnce();
        item.UseOnce();
    } else {
        player.ClientMessage("You used " $ item.ItemArticle @ item.ItemName $ " to save.");
        item.UseOnce();
    }
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
        SetGameSpeed(1);
        return;
    }

    if( p.dataLinkPlay != None ) {
        p.dataLinkPlay.AbortDataLink();
        interruptedDL = p.dataLinkPlay;
        p.dataLinkPlay = None;
    }

    saveSlot = -6;
    saveName = "DXR " $ dxr.seed @ dxr.flags.GameModeName(dxr.flags.gamemode) @ dxr.dxInfo.MissionLocation;
    lastMission = dxr.flagbase.GetInt('Rando_lastmission');

    isDifferentMission = dxr.dxInfo.MissionNumber != 0 && lastMission != dxr.dxInfo.MissionNumber;
    if( isDifferentMission || dxr.flags.autosave == ExtraSafe ) {
        saveSlot = 0;
    }
    dxr.flagbase.SetInt('Rando_lastmission', dxr.dxInfo.MissionNumber,, 999);

    info("doAutosave() " $ lastMission @ dxr.dxInfo.MissionNumber @ saveSlot @ saveName @ p.GetStateName() @ save_delay);
    bNeedSave = false;
    SetGameSpeed(1);// TODO: figure out what's wrong with using old_game_speed instead of 1
    class'DXRStats'.static.IncDataStorageStat(p, "DXRStats_autosaves");
    p.SaveGameCmd(saveSlot, saveName);
    Level.LevelAction = LEVACT_Saving;
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

simulated function PlayerLogin(#var(PlayerPawn) p)
{
    Super.PlayerLogin(p);

    if(IsLimitedSaves()) { // Limited Saves
        GiveItem(p, class'MemConUnit', 2);// start with 2?
    }
}

function bool IsFixedSaves()
{
    return dxr.flags.autosave==FixedSaves || dxr.flags.autosave==UnlimitedFixedSaves || dxr.flags.autosave==FixedSavesExtreme;
}

function bool IsLimitedSaves()
{
    return dxr.flags.autosave == FixedSaves || dxr.flags.autosave == LimitedSaves || dxr.flags.autosave==FixedSavesExtreme;
}

function MapAdjustments()
{
    local Actor a;
    local vector loc;
    local int i;

    if(IsLimitedSaves()) {
        SetSeed("spawn MCU");
        for(i=0; i<10; i++) {
            loc = GetRandomPositionFine();
            a = Spawn(class'MemConUnit',,, loc);
            if(a != None) {
                l("MapAdjustments() spawned MCU " $ a $ " at " $ loc);
                break;
            }
        }
    }
}

function string GetAutoSaveHelpText(coerce int choice)
{
    switch (choice)
    {
        case EveryEntry:
            return "The game will automatically save after every level transition.  You are allowed to save manually whenever you would like.  Autosaves are cleared when you progress to the next mission, except for the very first autosave of the mission.";
        case FirstEntry:
            return "The game will only automatically save the first time you enter a new level.  You are allowed to save manually whenever you would like.  Autosaves are cleared when you progress to the next mission, except for the very first autosave of the mission.";
        case Hardcore:
            return "The game will automatically save the first time you enter a level.  No manual saves are allowed.  Autosaves are cleared when you progress to the next mission, except for the very first autosave of the mission.";
        case ExtraSafe:
            return "The game will automatically save after every level transition.  You are allowed to save manually whenever you would like.  Autosaves are never cleared.";
        case LimitedSaves:
            return "The game will only autosave once at the start of the game.  Manual saves are allowed at any time, but require a Memory Containment Unit.  Memory Containment Units can be found randomly placed around levels.";
        case FixedSaves:
            return "The game will only autosave once at the start of the game.  Manual saves are only allowed when looking at a computer and require a Memory Containment Unit.  Memory Containment Units can be found randomly placed around levels.";
        case UnlimitedFixedSaves:
            return "The game will only autosave once at the start of the game.  Manual saves are only allowed when looking at a computer, but you are allowed to save as much as you would like.";
        case FixedSavesExtreme:
            return "The game will only autosave once at the start of the game.  Manual saves are only allowed when looking at a computer and require two(?) Memory Containment Units.  Memory Containment Units can be found randomly placed around levels.";
        case Disabled:
            return "The game will not automatically save.  You are allowed to save manually whenever you would like.";
        default:
            return ""; //This will mean the help button won't appear
    }
}
