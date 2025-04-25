//////////////////////////////////////////////////
// ListenAIEventTrigger
//
// This trigger is a bit unusual, as it gets instigated by listening
// for AI Events instead of being triggered or touched like normal.
//////////////////////////////////////////////////
class ListenAIEventTrigger extends Trigger;

//Who to listen to events from
var() bool listenScriptedPawn;
var() bool listenPlayer;
var() name listenTag;

//Which events to listen to
var() bool bListenFutz;
var() bool bListenMegaFutz;
var() bool bListenWeaponDrawn;
var() bool bListenWeaponFire;
var() bool bListenCarcass;
var() bool bListenLoudNoise;
var() bool bListenAlarm;
var() bool bListenDistress;
var() bool bListenProjectiles;

var() bool debugMessages;

//#region Toggle Functions
function ListenFutz(bool enable){
    bListenFutz=enable;
    if (enable){
        AISetEventCallback('Futz', 'HandleFutz', , true, true, false, true);
    } else {
        AIClearEventCallback('Futz');
    }
}

function ListenMegaFutz(bool enable){
    bListenMegaFutz=enable;
    if (enable){
        AISetEventCallback('MegaFutz', 'HandleMegaFutz', , true, true, true, true);
    } else {
        AIClearEventCallback('MegaFutz');
    }
}

function ListenWeaponDrawn(bool enable){
    bListenWeaponDrawn=enable;
    if (enable){
        //AISetEventCallback('WeaponDrawn', 'HandleWeaponDrawn', 'WeaponDrawnScore', true, true, false, true);
        AISetEventCallback('WeaponDrawn', 'HandleWeaponDrawn', , true, true, false, true);
    } else {
        AIClearEventCallback('WeaponDrawn');
    }
}

function ListenWeaponFire(bool enable){
    bListenWeaponFire=enable;
    if (enable){
        AISetEventCallback('WeaponFire', 'HandleWeaponFire', , true, true, false, true);
    } else {
        AIClearEventCallback('WeaponFire');
    }
}

function ListenCarcass(bool enable){
    bListenCarcass=enable;
    if (enable){
        //AISetEventCallback('Carcass', 'HandleCarcass', 'CarcassScore', true, true, false, true);
        AISetEventCallback('Carcass', 'HandleCarcass', , true, true, false, true);
    } else {
        AIClearEventCallback('Carcass');
    }
}

function ListenLoudNoise(bool enable){
    bListenLoudNoise=enable;
    if (enable){
        //AISetEventCallback('LoudNoise', 'HandleLoudNoise', 'LoudNoiseScore');
        AISetEventCallback('LoudNoise', 'HandleLoudNoise', );
    } else {
        AIClearEventCallback('LoudNoise');
    }
}

function ListenAlarm(bool enable){
    bListenAlarm=enable;
    if (enable){
        AISetEventCallback('Alarm', 'HandleAlarm');
    } else {
        AIClearEventCallback('Alarm');
    }
}

function ListenDistress(bool enable){
    bListenDistress=enable;
    if (enable){
        //AISetEventCallback('Distress', 'HandleDistress', 'DistressScore', true, true, false, true);
        AISetEventCallback('Distress', 'HandleDistress', , true, true, false, true);
    } else {
        AIClearEventCallback('Distress');
    }
}

function ListenProjectiles(bool enable){
    bListenProjectiles=enable;
    if (enable){
        AISetEventCallback('Projectile', 'HandleProjectiles', , false, true, false, true);
    } else {
        AIClearEventCallback('Projectile');
    }
}

//#endregion

//#region Utility Functions
function SendTestMsg(Name event, XAIParams params)
{
    local #var(PlayerPawn) p;

    if (!debugMessages) return;

    p=#var(PlayerPawn)(GetPlayerPawn());

    p.ClientMessage(Self$" Event: "$event$"  BestActor: "$params.BestActor$"  Score: "$params.Score$"  Visibility: "$params.Visibility$"  Volume: "$params.Volume);
}

function TriggerOthers(XAIParams params)
{
    local Actor A;
    if (Event != '')
        foreach AllActors(class 'Actor', A, Event)
            A.Trigger(Self, Pawn(params.BestActor));

    if(bTriggerOnceOnly) Destroy();
}

function bool IsRelevant(actor bestActor)
{
    local #var(prefix)ScriptedPawn sp;
    local #var(PlayerPawn) pp;

    if (bestActor==None) return false;

    sp = #var(prefix)ScriptedPawn(bestActor);
    pp = #var(PlayerPawn)(bestActor);

    if (listenTag!=''){
        if (bestActor.Tag!=listenTag) return false;
    }

    if (sp!=None && listenScriptedPawn) return true;
    if (pp!=None && listenPlayer)       return true;

    return false;
}
//#endregion

//#region Handle Events
function HandleFutz(Name event, EAIEventState state, XAIParams params)
{
    if (!IsRelevant(params.BestActor)) return;
    SendTestMsg(event,params);
    TriggerOthers(params);
}


function HandleMegaFutz(Name event, EAIEventState state, XAIParams params)
{
    if (state != EAISTATE_Begin) return;

    //MegaFutz is only player-triggerable and reports
    //BestActor as the thing being mega-futzed with
    params.BestActor = GetPlayerPawn();

    if (!IsRelevant(params.BestActor)) return;
    SendTestMsg(event,params);
    TriggerOthers(params);
}

function HandleWeaponDrawn(Name event, EAIEventState state, XAIParams params)
{
    local #var(DeusExPrefix)Weapon w;

    //Report the gun holder as best actor, not the gun itself
    w=#var(DeusExPrefix)Weapon(params.BestActor);
    if (w==None) return;
    if (w.Owner==None) return;
    params.BestActor=w.Owner; //Should be the person holding the weapon

    if (!IsRelevant(params.BestActor)) return;

    SendTestMsg(event,params);
    TriggerOthers(params);
}

function HandleWeaponFire(Name event, EAIEventState state, XAIParams params)
{
    if (!IsRelevant(params.BestActor)) return;

    SendTestMsg(event,params);
    TriggerOthers(params);
}


//This is kind of weird, since ScriptedPawn's don't actually use the AI Events to detect carcasses.
function HandleCarcass(Name event, EAIEventState state, XAIParams params)
{
    local #var(DeusExPrefix)Carcass c;

    c=#var(DeusExPrefix)Carcass(params.BestActor);
    if (c!=None){
        if (c.bNotDead) return; //Unconscious bodies shouldn't be noticed?
        if (c.KillerBindName==class'#var(PlayerPawn)'.Default.BindName){
            params.BestActor = GetPlayerPawn();
        }
    }

    if (!IsRelevant(params.BestActor)) return;

    SendTestMsg(event,params);
    TriggerOthers(params);
}


function HandleLoudNoise(Name event, EAIEventState state, XAIParams params)
{
    local #var(DeusExPrefix)Decoration d;

    //If it's a decoration, report the person that made it move
    //(presumably the player)
    d=#var(DeusExPrefix)Decoration(params.BestActor);
    if (d!=None){
        if (d.Instigator!=None){
            params.BestActor=d.Instigator;
        }
    }

    if (!IsRelevant(params.BestActor)) return;

    SendTestMsg(event,params);
    TriggerOthers(params);
}

function HandleAlarm(Name event, EAIEventState state, XAIParams params)
{
    local #var(prefix)AlarmUnit      alarm;
    local #var(prefix)LaserTrigger   laser;
    local #var(prefix)SecurityCamera camera;
    local #var(prefix)Computers      computer;
    local Pawn                       alarmInstigator;

    if (!(state == EAISTATE_Begin || state == EAISTATE_Pulse)) return;

    alarm    = #var(prefix)AlarmUnit(params.bestActor);
    laser    = #var(prefix)LaserTrigger(params.bestActor);
    camera   = #var(prefix)SecurityCamera(params.bestActor);
    computer = #var(prefix)Computers(params.bestActor);
    if (alarm != None)
    {
        alarmInstigator = alarm.alarmInstigator;
    }
    else if (laser != None)
    {
        alarmInstigator = Pawn(laser.triggerActor);
        if (alarmInstigator == None)
            alarmInstigator = laser.triggerActor.Instigator;
    }
    else if (camera != None)
    {
        alarmInstigator = GetPlayerPawn();  // player is implicit for cameras
    }
    else if (computer != None)
    {
        alarmInstigator = GetPlayerPawn();  // player is implicit for computers
    }

    if (alarmInstigator!=None){
        params.BestActor=alarmInstigator;
    }

    if (!IsRelevant(params.BestActor)) return;

    SendTestMsg(event,params);
    TriggerOthers(params);
}

function HandleDistress(Name event, EAIEventState state, XAIParams params)
{
    if (!IsRelevant(params.BestActor)) return;

    SendTestMsg(event,params);
    TriggerOthers(params);
}

function HandleProjectiles(Name event, EAIEventState state, XAIParams params)
{
    local #var(DeusExPrefix)Projectile p;

    //Report the gun holder as best actor, not the gun itself
    p=#var(DeusExPrefix)Projectile(params.BestActor);
    if (p==None) return;
    if (p.Owner==None) return;
    params.BestActor=p.Owner; //Should be the person who fired the projectile

    if (!IsRelevant(params.BestActor)) return;

    SendTestMsg(event,params);
    TriggerOthers(params);
}
//#endregion


function Touch(Actor Other)
{
    //Literally do nothing
}

event Trigger( Actor Other, Pawn EventInstigator )
{
    //Literally do nothing
}


function BeginPlay()
{
    ListenFutz(bListenFutz);
    ListenMegaFutz(bListenMegaFutz);
    ListenWeaponDrawn(bListenWeaponDrawn);
    ListenWeaponFire(bListenWeaponFire);
    ListenCarcass(bListenCarcass);
    ListenLoudNoise(bListenLoudNoise);
    ListenAlarm(bListenAlarm);
    ListenDistress(bListenDistress);
    ListenProjectiles(bListenProjectiles);
}

//#region Initializer
static function ListenAIEventTrigger Create(Actor a,
                                            vector loc,
                                            name event,
                                            bool pawns,
                                            bool players,
                                            optional name listenTag,
                                            optional bool futz,
                                            optional bool megafutz,
                                            optional bool weapondraw,
                                            optional bool weaponfire,
                                            optional bool carcass,
                                            optional bool loudnoise,
                                            optional bool alarm,
                                            optional bool distress,
                                            optional bool projectiles)
{
    local ListenAIEventTrigger laiet;

    laiet = a.Spawn(class'ListenAIEventTrigger',,,loc);
    laiet.Event=event;
    laiet.listenTag=listenTag;
    laiet.listenScriptedPawn=pawns;
    laiet.listenPlayer=players;

    laiet.ListenFutz(futz);
    laiet.ListenMegaFutz(megafutz);
    laiet.ListenWeaponDrawn(weapondraw);
    laiet.ListenWeaponFire(weaponfire);
    laiet.ListenCarcass(carcass);
    laiet.ListenLoudNoise(loudnoise);
    laiet.ListenAlarm(alarm);
    laiet.ListenDistress(distress);
    laiet.ListenProjectiles(projectiles);

    return laiet;
}
//#endregion

defaultproperties
{
    bAlwaysRelevant=true
    bCollideActors=false
    bCollideWorld=false
    bBlockActors=false
    bBlockPlayers=false
    bTriggerOnceOnly=false
    listenScriptedPawn=true
    listenPlayer=true
    debugMessages=false
}
