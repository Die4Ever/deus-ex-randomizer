class DXREventsBase extends DXRActorsBase;

var bool died;
var name watchflags[32];
var int num_watchflags;
var int bingo_win_countdown;
var name rewatchflags[8];
var int num_rewatchflags;
var float PoolBallHeight;
var int NumPoolTables, PoolTablesSunk, BallsPerTable;

struct BingoOption {
    var string event, desc;
    var int max;
    var int missions;// bit masks
};
var BingoOption bingo_options[350];

struct MutualExclusion {
    var string e1, e2;
};
var MutualExclusion mutually_exclusive[64];

struct ActorWatchItem {
    var Actor a;
    var String BingoEvent;
};
var ActorWatchItem actor_watch[100];
var int num_watched_actors;

simulated function string tweakBingoDescription(string event, string desc);
function string RemapBingoEvent(string eventname);
simulated function bool WatchGuntherKillSwitch();
function SetWatchFlags();

function AddWatchedActor(Actor a,String eventName)
{
    if (num_watched_actors>=ArrayCount(actor_watch)){
        err("Watched Actor list length exceeded!");
        return;
    }

    actor_watch[num_watched_actors].a = a;
    actor_watch[num_watched_actors].BingoEvent=eventName;
    num_watched_actors++;
}

function CheckWatchedActors() {
    local int i;

    for (i=0;i<num_watched_actors;i++){
        //I think this reference keeps the actor from actually being destroyed, so just watch for bDeleteMe
        if (actor_watch[i].a != None && !actor_watch[i].a.bDeleteMe) continue;

        _MarkBingo(actor_watch[i].BingoEvent);
        num_watched_actors--;
        actor_watch[i] = actor_watch[num_watched_actors];
        i--;// recheck this slot on the next iteration
    }
}

function PreFirstEntry()
{
    Super.PreFirstEntry();

    switch(dxr.dxInfo.missionNumber) {
        case 99:
            Ending_FirstEntry();
            break;

        default:
            // if any mission has a lot of flags then it can get its own case and function
            SetWatchFlags();
            break;
    }
}

function PostFirstEntry()
{
    Super.PostFirstEntry();

     //Done here so that items you are carrying over between levels don't get hit by LogPickup
    InitStatLogShim();
}

function InitStatLogShim()
{
    //I think both LocalLog and WorldLog will always be None in DeusEx, but if this makes it
    //to another game, might need to actually see if there's a possibility of overlap here.
    if (!((Level.Game.LocalLog!=None && Level.Game.LocalLog.IsA('DXRStatLog')) ||
          (Level.Game.WorldLog!=None && Level.Game.WorldLog.IsA('DXRStatLog')))){
        if (Level.Game.LocalLog==None){
            Level.Game.LocalLog=spawn(class'DXRStatLog');
        } else if (Level.Game.WorldLog==None){
            Level.Game.WorldLog=spawn(class'DXRStatLog');
        }
    }
}

function WatchFlag(name flag, optional bool disallow_immediate) {
    // disallow_immediate means it will still be added to the watch list, but won't be checked in the first tick
    // this is good for flag names that get reused and need to be cleared by the MissionScript, like MS_DL_Played
    if( (!disallow_immediate) && dxr.flagbase.GetBool(flag) ) {
        SendFlagEvent(flag, true);
        return;
    }
    watchflags[num_watchflags++] = flag;
    if(num_watchflags > ArrayCount(watchflags))
        err("WatchFlag num_watchflags > ArrayCount(watchflags)");
}

//Only actually add the flag to the list if it isn't already set
function RewatchFlag(name flag, optional bool disallow_immediate){
    if (!dxr.flagbase.GetBool(flag)) {
        WatchFlag(flag,disallow_immediate);
        // rewatchflags will get checked in AnyEntry so they can be removed
        rewatchflags[num_rewatchflags++] = flag;
    } else {
        l("RewatchFlag "$flag$" is already set!");
    }
}

function ReportMissingFlag(name flag, string eventname) {
    if( ! dxr.flagbase.GetBool(flag) ) {
        SendFlagEvent(eventname, true);
    }
}

function Ending_FirstEntry()
{
    local int ending;

    ending = 0;

    switch(dxr.localURL)
    {
        //Make sure we actually are only running on the endgame levels
        //Just in case we hit a custom level with mission 99 or something
        case "ENDGAME1": //Tong
            ending = 1;
            break;
        case "ENDGAME2": //Helios
            ending = 2;
            break;
        case "ENDGAME3": //Everett
            ending = 3;
            break;
        case "ENDGAME4": //Dance party
        case "ENDGAME4REV": //Dance party
            ending = 4;
            break;
        default:
            //In case rando runs some player level or something with mission 99
            break;
    }

    if (ending!=0){
        //Notify of game completion with correct ending number
        BeatGame(dxr,ending);
    }
}

simulated function AnyEntry()
{
    local int r, w;
    Super.AnyEntry();
    SetTimer(1, true);

    for(w=0; w<ArrayCount(watchflags); w++) {
        if(watchflags[w]!='')
            l("AnyEntry watchflags["$w$"]: "$watchflags[w]);
    }

    // any rewatch flags that were set outside of this map need to be cleared from the watch list
    for(r=0; r<ArrayCount(rewatchflags); r++) {
        if(rewatchflags[r] == '') continue;
        l("AnyEntry rewatchflags["$r$"]: "$rewatchflags[r]);
        if (dxr.flagbase.GetBool(rewatchflags[r])) {
            l("AnyEntry rewatchflags["$r$"]: "$rewatchflags[r]$" is set!");
            for(w=0; w<num_watchflags; w++) {
                if(watchflags[w] != rewatchflags[r]) continue;

                num_watchflags--;
                watchflags[w] = watchflags[num_watchflags];
                watchflags[num_watchflags]='';
                w--;
            }
        }
    }
}

simulated function bool ClassInLevel(class<Actor> className)
{
    local Actor a;

    foreach AllActors(className,a){
        return True;
    };
    return False;
}

simulated function int PoolBallsSunk()
{
    local #var(injectsprefix)Poolball cue,ball;
    local int ballsSunk,tablesSunk,freshSink,radius;

    radius=99999;

    //I think Airfield is the only map with more than one,
    //Need to make sure we only count the balls for each individual table.
    //Those pool tables don't have anywhere for the balls to fall out, so
    //radius can be contained.  Other tables have a hole for the balls to
    //come out, so we want to be able to check a larger radius.
    if (NumPoolTables>1){
        radius = 150;
    }

    tablesSunk=0;
    foreach AllActors(class'#var(injectsprefix)Poolball',cue){
        if (cue.Class!=class'#var(injectsprefix)Poolball') continue;
        if (cue.SkinColor==SC_Cue){
            ballsSunk=0;
            foreach cue.RadiusActors(class'#var(injectsprefix)Poolball',ball,radius){
                if (ball.Class!=class'#var(injectsprefix)Poolball') continue;
                if (ball.Location.Z <= PoolBallHeight){
                    ballsSunk++;
                }
            }
            if (ballsSunk>=BallsPerTable){
                tablesSunk++;
            }
        }
    }

    if (tablesSunk <= PoolTablesSunk){
        return 0;
    }
    freshSink = tablesSunk-PoolTablesSunk;
    PoolTablesSunk = tablesSunk;

    return freshSink;
}

simulated function InitPoolBalls()
{
    local #var(prefix)Poolball ball;
    PoolBallHeight = 9999;
    NumPoolTables=0;
    PoolTablesSunk=0;

    foreach AllActors(class'#var(prefix)Poolball',ball){
        if (ball.Location.Z < PoolBallHeight){
            PoolBallHeight = ball.Location.Z;
        }
        if (ball.SkinColor==SC_Cue){
            NumPoolTables+=1;
        }
    }

    BallsPerTable = 16; //Default number - Lucky Money has less

    PoolBallHeight -= 1;
}

simulated function bool CheckForNanoKey(String keyID)
{

    local name keyName;

    if (player()==None){
        return False;
    }

    if (player().KeyRing==None){
        return False;
    }

    keyName = StringToName(keyID);

    return player().KeyRing.HasKey(keyName);
}

simulated function Timer()
{
    local int i,j,num;
    local bool FlagTriggered;

    if( dxr == None || dxr.flagbase == None ) {
        return;
    }

    CheckWatchedActors();

    for(i=0; i<num_watchflags; i++) {
        if(watchflags[i] == '') break;

        if( watchflags[i] == 'MS_DL_Played' && dxr.flagbase.GetBool('PlayerTraveling') ) {
            continue;
        }

        FlagTriggered = False;
        switch(watchflags[i]) {
        case 'LeoToTheBar':
            FlagTriggered = ClassInLevel(class'#var(prefix)TerroristCommanderCarcass');
            break;

        case 'PaulToTong':
            FlagTriggered = ClassInLevel(class'PaulDentonCarcass');
            break;

        case 'GuntherKillswitch':
            if (WatchGuntherKillSwitch()){
                FlagTriggered=True;
                _MarkBingo("GuntherHermann_Dead");
            }
            break;

        case 'PlayPool':
            // we don't set FlagTriggered=true, just handle it all here to know when to delete this watcher
            num = PoolBallsSunk();
            if (num>0){
                for (j=0;j<num;j++){
                    SendFlagEvent(watchflags[i]);
                }
                if (PoolTablesSunk >= NumPoolTables){
                    num_watchflags--;
                    watchflags[i] = watchflags[num_watchflags];
                    watchflags[num_watchflags]='';
                    i--;
                }
            }
            break;

        case 'FlowersForTheLab':
            FlagTriggered = ClassInLevel(class'#var(prefix)Flowers');
            break;

        default:
            if (InStr(watchflags[i],"WatchKeys_")!=-1) {
                FlagTriggered = CheckForNanoKey(Mid(watchflags[i],10));
            } else {
                FlagTriggered = dxr.flagbase.GetBool(watchflags[i]);
            }
            break;
        }

        if( FlagTriggered ) {
            SendFlagEvent(watchflags[i]);
            num_watchflags--;
            watchflags[i] = watchflags[num_watchflags];
            watchflags[num_watchflags]='';
            i--;
        }
    }
    // for nonvanilla, because GameInfo.Died is called before the player's Dying state calls root.ClearWindowStack();
    if(died) {
        class'DXRHints'.static.AddDeath(dxr, player());
        died = false;
    }

    if (bingo_win_countdown>=0){
        HandleBingoWinCountdown();
    }
}

function BingoWinScreen()
{
    local #var(PlayerPawn) p;
    local bool showMsg;

    p = player();
    if ( Level.Netmode == NM_Standalone ) {
        //Make it harder to get murdered during the countdown
        //For whatever reason, you can set the game speed in Revision,
        //but it doesn't stick.  Just don't bother.
        if (!#defined(revision)){
            Level.Game.SetGameSpeed(0.1);
        }
        SetTimer(Level.Game.GameSpeed, true);
    }
    p.ReducedDamageType = 'All';// god mode
    p.DesiredFlashScale = 0;
    p.DesiredFlashFog = vect(0,0,0);

    showMsg=False;
    if (InGame()){
        showMsg=True;
    } else {
        //Consider it in-game if a big message is up...
        if (DXRBigMessage(DeusExRootWindow(p.rootWindow).GetTopWindow()) != None){
            showMsg = True;
        }
    }

    if(showMsg) {
        p.ShowHud(False);
        //Show win message
        class'DXRBigMessage'.static.CreateBigMessage(dxr.player,None,"Congratulations!  You finished your bingo!","Game ending in "$bingo_win_countdown$" seconds");
    }
    if (bingo_win_countdown == 2 && !#defined(vanilla)) {
        //Give it 2 seconds to send the tweet
        //This is still needed outside of vanilla
        BeatGame(dxr,4);
    }
}

function HandleBingoWinCountdown()
{
    //Blocked in HX for now (Blocked at the check, but here for safety as well)
    if(#defined(hx)) return;

    //Only do the countdown while outside of menus
    if (!InGame() && (DXRBigMessage(DeusExRootWindow(player().rootWindow).GetTopWindow()) == None)) return;

    if (bingo_win_countdown > 0) {
        BingoWinScreen();
        bingo_win_countdown--;
    } else if (bingo_win_countdown == 0) {
        if ( Level.Netmode == NM_Standalone ) {
            Level.Game.SetGameSpeed(1);
            SetTimer(1, true);
        }
        //Go to bingo win ending
        Level.Game.SendPlayer(dxr.player,"99_EndGame4");
    }
}

function bool SpecialTriggerHandling(Actor Other, Pawn Instigator)
{
    local #var(prefix)MapExit m;
    if (tag == 'Boat_Exit'){
        dxr.flagbase.SetBool('DXREvents_LeftOnBoat', true,, 999);

        foreach AllActors(class'#var(prefix)MapExit',m,'Boat_Exit2'){
            m.Trigger(Other,Instigator);
        }
        return true;
    }

    return false;
}

function Trigger(Actor Other, Pawn Instigator)
{
    local string j;
    local class<Json> js;
    local name useTag;

    js = class'Json';

    //Leave this variable for now, in case we need to massage tags
    //again at some point in the future
    useTag = tag;

    Super.Trigger(Other, Instigator);
    l("Trigger("$Other$", "$instigator$")");

    if (!SpecialTriggerHandling(Other,Instigator)){
        j = js.static.Start("Trigger");
        js.static.Add(j, "instigator", GetActorName(Instigator));
        js.static.Add(j, "tag", useTag);
        js.static.add(j, "other", GetActorName(other));
        GeneralEventData(dxr, j);
        js.static.End(j);

        class'DXRTelemetry'.static.SendEvent(dxr, Instigator, j);
        _MarkBingo(useTag);
    }
}

function SendFlagEvent(coerce string eventname, optional bool immediate, optional string extra)
{
    local string j;
    local class<Json> js;
    js = class'Json';

    l("SendFlagEvent " $ eventname @ immediate @ extra);

    if(eventname ~= "M02HostagesRescued") {// for the hotel, set by Mission02.uc
        M02HotelHostagesRescued();
        return;
    }
    else if(eventname ~= "MS_DL_Played") {// this is a generic flag name used in a few of the mission scripts
        if(dxr.localURL ~= "02_NYC_BATTERYPARK") {
            BatteryParkHostages();
        }
        return;
    }

    j = js.static.Start("Flag");
    js.static.Add(j, "flag", eventname);
    js.static.Add(j, "immediate", immediate);
    js.static.Add(j, "location", vectclean(dxr.player.location));
    if(extra != "")
        js.static.Add(j, "extra", extra);
    GeneralEventData(dxr, j);
    js.static.End(j);

    class'DXRTelemetry'.static.SendEvent(dxr, dxr.player, j);
    _MarkBingo(eventname);
}

function M02HotelHostagesRescued()
{
    local bool MaleHostage_Dead, FemaleHostage_Dead, GilbertRenton_Dead;
    MaleHostage_Dead = dxr.flagbase.GetBool('MaleHostage_Dead');
    FemaleHostage_Dead = dxr.flagbase.GetBool('FemaleHostage_Dead');
    GilbertRenton_Dead = dxr.flagbase.GetBool('GilbertRenton_Dead');
    if( !MaleHostage_Dead && !FemaleHostage_Dead && !GilbertRenton_Dead) {
        SendFlagEvent("HotelHostagesSaved");
    }
}

function BatteryParkHostages()
{
    local bool SubTerroristsDead, EscapeSuccessful, SubHostageMale_Dead, SubHostageFemale_Dead;
    SubTerroristsDead = dxr.flagbase.GetBool('SubTerroristsDead');
    EscapeSuccessful = dxr.flagbase.GetBool('EscapeSuccessful');
    SubHostageMale_Dead = dxr.flagbase.GetBool('SubHostageMale_Dead');
    SubHostageFemale_Dead = dxr.flagbase.GetBool('SubHostageFemale_Dead');

    l("BatteryParkHostages() " $ SubTerroristsDead @ EscapeSuccessful @ SubHostageMale_Dead @ SubHostageFemale_Dead);
    if( (SubTerroristsDead || EscapeSuccessful) && !SubHostageMale_Dead && !SubHostageFemale_Dead ) {
        SendFlagEvent("SubwayHostagesSaved");
    }
}

static function _DeathEvent(DXRando dxr, Actor victim, Actor Killer, coerce string damageType, vector HitLocation, string type)
{
    local string j;
    local class<Json> js;
    local bool unconcious;
    js = class'Json';

    j = js.static.Start(type);
    js.static.Add(j, "victim", GetActorName(victim));
    js.static.Add(j, "victimBindName", victim.BindName);
    js.static.Add(j, "victimRandomizedName", GetRandomizedName(victim));
    if(#var(prefix)ScriptedPawn(victim) != None) {
        unconcious = #var(prefix)ScriptedPawn(victim).bStunned;
        js.static.Add(j, "victimUnconcious", unconcious);
    }

    if(Killer != None) {
        js.static.Add(j, "killerclass", Killer.Class.Name);
        js.static.Add(j, "killer", GetActorName(Killer));
        js.static.Add(j, "killerRandomizedName", GetRandomizedName(Killer));
    }
    js.static.Add(j, "dmgtype", damageType);
    GeneralEventData(dxr, j);
    js.static.Add(j, "location", dxr.flags.vectclean(victim.Location));
    js.static.End(j);
    class'DXRTelemetry'.static.SendEvent(dxr, victim, j);
}

static function string GetRandomizedName(Actor a)
{
    local ScriptedPawn sp;
    sp = ScriptedPawn(a);
    if(sp == None || sp.bImportant) return "";
    return sp.FamiliarName;
}

static function AddPlayerDeath(DXRando dxr, #var(PlayerPawn) player, optional Actor Killer, optional coerce string damageType, optional vector HitLocation)
{
    local DXREvents ev;
    class'DXRStats'.static.AddDeath(player);

    if(#defined(injections))
        class'DXRHints'.static.AddDeath(dxr, player);
    else {
        // for nonvanilla, because GameInfo.Died is called before the player's Dying state calls root.ClearWindowStack();
        ev = DXREvents(dxr.FindModule(class'DXREvents'));
        if(ev != None)
            ev.died = true;
    }

    if(Killer == None) {
        if(player.myProjKiller != None)
            Killer = player.myProjKiller;
        if(player.myTurretKiller != None)
            Killer = player.myTurretKiller;
        if(player.myPoisoner != None)
            Killer = player.myPoisoner;
        if(player.myBurner != None)
            Killer = player.myBurner;
        // myKiller is only set in multiplayer
        if(player.myKiller != None)
            Killer = player.myKiller;
    }

    if(damageType == "shot") {
        if( !IsHuman(Killer.class) && Robot(Killer) == None ) {
            // only humans and robots can shoot? karkians deal shot damage
            damageType = "";
        }
    }

    _DeathEvent(dxr, player, Killer, damageType, HitLocation, "DEATH");
}

static function AddPawnDeath(ScriptedPawn victim, optional Actor Killer, optional coerce string damageType, optional vector HitLocation)
{
    local DXRando dxr;
    local DXREvents e;
    foreach victim.AllActors(class'DXRando', dxr) break;

    if(dxr != None)
        e = DXREvents(dxr.FindModule(class'DXREvents'));
    log(e$".AddPawnDeath "$dxr$", "$victim);
    if(e != None)
        e._AddPawnDeath(victim, Killer, damageType, HitLocation);
}

function bool checkInitialAlliance(ScriptedPawn p,name allianceName, float allianceLevel)
{
    local int i;

    for (i=0;i<8;i++){
        if (p.InitialAlliances[i].AllianceName==allianceName &&
            p.InitialAlliances[i].AllianceLevel~=allianceLevel){
            return True;
        }
    }
    return False;
}

function bool isInitialPlayerAlly(ScriptedPawn p)
{
    return checkInitialAlliance(p,'Player',1.0);
}

function bool isInitialPlayerEnemy(ScriptedPawn p)
{
    return checkInitialAlliance(p,'Player',-1.0);
}

function _AddPawnDeath(ScriptedPawn victim, optional Actor Killer, optional coerce string damageType, optional vector HitLocation)
{
    local string classname;
    local bool dead;

    dead = !FixScriptedPawn(victim).CanKnockUnconscious(damageType);

    if (dead){
        _MarkBingo(victim.BindName$"_Dead");
        _MarkBingo(victim.BindName$"_DeadM" $ dxr.dxInfo.missionNumber);
    } else {
        _MarkBingo(victim.BindName$"_Unconscious");
        _MarkBingo(victim.BindName$"_UnconsciousM" $ dxr.dxInfo.missionNumber);
    }

    //Burned doesn't track who set them on fire...
    //The intent here is to only mark bingo for kills done by the player
    if( (Killer == None  && damageType=="Burned") || #var(PlayerPawn)(Killer) != None ) {
        classname = string(victim.class.name);

        if(#defined(hx) && InStr(classname, "HX")==0) {
            classname = Mid(classname, 2);
        }

        if (!dead){
            _MarkBingo(classname$"_ClassUnconscious");
            _MarkBingo(classname$"_ClassUnconsciousM" $ dxr.dxInfo.missionNumber);
            _MarkBingo(victim.alliance$"_AllianceUnconscious");
            _MarkBingo(victim.bindName$"_BindNameUnconscious");
            class'DXRStats'.static.AddKnockOut(player());
        } else {
            _MarkBingo(classname$"_ClassDead");
            _MarkBingo(classname$"_ClassDeadM" $ dxr.dxInfo.missionNumber);
            _MarkBingo(victim.alliance$"_AllianceDead");
            _MarkBingo(victim.bindName$"_BindNameDead");
            class'DXRStats'.static.AddKill(player());

            //Were they an ally?  Skip on NSF HQ, because that's kind of a bait
            if (
                !isInitialPlayerEnemy(victim) && //Must have not been an enemy initially
                IsHuman(victim.class) && //There's no such thing as an innocent Cat
                ( dxr.localURL!="04_NYC_NSFHQ" || dxr.flagbase.GetBool('NSFSignalSent')==False ) //Not on the NSF HQ map, or if it is, before you send the signal (kludgy)
            ) {
                _MarkBingo("AlliesKilled");
            }
        }
        if (damageType=="stomped" && IsHuman(victim.class)){ //If you stomp a human to death...
            _MarkBingo("HumanStompDeath");
        }

    } else {
        if (!dead) {
            class'DXRStats'.static.AddKnockOutByOther(player());
        } else {
            class'DXRStats'.static.AddKillByOther(player());
        }
    }

    if(!victim.bImportant)
        return;

    switch (victim.BindName) {
        case "PaulDenton":
            dxr.flagbase.SetBool('DXREvents_PaulDead', true,, 999);
            break;
        case "AnnaNavarre":
            if (dxr.flagbase.GetBool('annadies')) {
                _MarkBingo("AnnaKillswitch");
                Killer = player();
            }
            break;
        case "JuanLebedev":
            class'DXREventsBase'.static.MarkBingoAsFailed(dxr, "LebedevLived");
            break;
        case "Aimee":
        case "LeMerchant":
            class'DXREventsBase'.static.MarkBingoAsFailed(dxr, "AimeeLeMerchantLived");
            break;
        case "MaggieChow":
            class'DXREventsBase'.static.MarkBingoAsFailed(dxr, "MaggieLived");
            break;
    }

    _DeathEvent(dxr, victim, Killer, damageType, HitLocation, "PawnDeath");
}

static function AddDeath(Pawn victim, optional Actor Killer, optional coerce string damageType, optional vector HitLocation)
{
    local DXRando dxr;
    local #var(PlayerPawn) player;
    local #var(prefix)ScriptedPawn sp;
    player = #var(PlayerPawn)(victim);
    sp = #var(prefix)ScriptedPawn(victim);
    if(player != None) {
        foreach victim.AllActors(class'DXRando', dxr) break;
        AddPlayerDeath(dxr, player, Killer, damageType, HitLocation);
    }
    else if(sp != None)
        AddPawnDeath(sp, Killer, damageType, HitLocation);
}

static function PaulDied(DXRando dxr)
{
    local string j;
    local class<Json> js;
    js = class'Json';

    j = js.static.Start("PawnDeath");
    js.static.Add(j, "victim", "Paul Denton");
    js.static.Add(j, "victimBindName", "PaulDenton");
    js.static.Add(j, "dmgtype", "");
    GeneralEventData(dxr, j);
    js.static.Add(j, "location", dxr.flags.vectclean(dxr.player.location));
    js.static.End(j);
    dxr.flagbase.SetBool('DXREvents_PaulDead', true,, 999);
    class'DXRTelemetry'.static.SendEvent(dxr, dxr.player, j);
    MarkBingo(dxr, "PaulDenton_Dead");
}

static function SavedPaul(DXRando dxr, #var(PlayerPawn) player, optional int health)
{
    local string j;
    local class<Json> js;
    js = class'Json';

    j = js.static.Start("SavedPaul");
    if(health > 0)
        js.static.Add(j, "PaulHealth", health);
    GeneralEventData(dxr, j);
    js.static.End(j);

    class'DXRTelemetry'.static.SendEvent(dxr, dxr.player, j);
    MarkBingo(dxr, "SavedPaul");
}

static function BeatGame(DXRando dxr, int ending)
{
    local PlayerDataItem data;
    local DXRStats stats;
    local string j;
    local class<Json> js;
    js = class'Json';

    // Mark the rando as having been beaten, affects dialogs on the new game menu.
    dxr.rando_beaten = Max(1, dxr.rando_beaten + 1);
    dxr.rando_beaten = Min(2000000000, dxr.rando_beaten);// Make sure you can beat the game over 2 billion times without overflow issues.
    dxr.SaveConfig();

    stats = DXRStats(dxr.FindModule(class'DXRStats'));

    j = js.static.Start("BeatGame");
    js.static.Add(j, "ending", ending);
    js.static.Add(j, "SaveCount", dxr.player.saveCount);
    js.static.Add(j, "Autosaves", stats.GetDataStorageStat(dxr, "DXRStats_autosaves"));
    js.static.Add(j, "deaths", stats.GetDataStorageStat(dxr, "DXRStats_deaths"));
    js.static.Add(j, "LoadCount", stats.GetDataStorageStat(dxr, "DXRStats_loads"));
    js.static.Add(j, "maxrando", dxr.flags.maxrando);
    js.static.Add(j, "bSetSeed", dxr.flags.bSetSeed);
    data = class'PlayerDataItem'.static.GiveItem(dxr.player);
    js.static.Add(j, "initial_version", data.initial_version);
    js.static.Add(j, "combat_difficulty", dxr.player.CombatDifficulty);
    js.static.Add(j, "rando_difficulty", dxr.flags.difficulty);
    js.static.Add(j, "cheats", dxr.player.FlagBase.GetInt('DXRStats_cheats'));

    if (dxr.player.carriedDecoration!=None){
        js.static.Add(j, "carriedItem", dxr.player.carriedDecoration.Class);
    }
    else if(dxr.player.inHand.IsA('POVCorpse')){
        js.static.Add(j, "carriedItem", POVCorpse(dxr.player.inHand).carcClassString);
    }

    GeneralEventData(dxr, j);
    BingoEventData(dxr, j);
    AugmentationData(dxr, j);
    GameTimeEventData(dxr, j);

    js.static.Add(j, "score", stats.ScoreRun());
    js.static.End(j);

    class'DXRTelemetry'.static.SendEvent(dxr, dxr.player, j);
}

static function ExtinguishFire(DXRando dxr, string extinguisher, DeusExPlayer player)
{
    local string j;
    local class<Json> js;
    js = class'Json';

    j = js.static.Start("ExtinguishFire");
    js.static.Add(j, "extinguisher", extinguisher);
    js.static.Add(j, "location", dxr.flags.vectclean(player.Location));
    GeneralEventData(dxr, j);
    js.static.End(j);

    class'DXRTelemetry'.static.SendEvent(dxr, player, j);
    MarkBingo(dxr, "ExtinguishFire");
}

static function GeneralEventData(DXRando dxr, out string j)
{
    local string loadout,lang;
    local class<Json> js;
    js = class'Json';

    js.static.Add(j, "PlayerName", GetActorName(dxr.player));
    js.static.Add(j, "map", dxr.localURL);
    js.static.Add(j, "mapname", dxr.dxInfo.MissionLocation);
    js.static.Add(j, "mission", dxr.dxInfo.missionNumber);
    js.static.Add(j, "TrueNorth", dxr.dxInfo.TrueNorth);
    js.static.Add(j, "PlayerIsFemale", dxr.flagbase.GetBool('LDDPJCIsFemale'));
    js.static.Add(j, "GameMode", dxr.flags.GameModeName(dxr.flags.gamemode));
    js.static.Add(j, "newgameplus_loops", dxr.flags.newgameplus_loops);

    loadout = GetLoadoutName(dxr);
    if(loadout != "")
        js.static.Add(j, "loadout", loadout);

    lang = GetConfig("Engine.Engine", "Language");
    if(lang != "")
        js.static.Add(j, "language", lang);
}

static function AugmentationData(DXRando dxr, out string j)
{
    local Augmentation anAug;
    local string augId,augName,augInfo;
    local int level;

    anAug = dxr.player.AugmentationSystem.FirstAug;
    while(anAug != None)
    {
        if (anAug.HotKeyNum <= 0){ //I think if you uninstall an aug it becomes -1?
            anAug = anAug.next;
            continue;
        }
        augId = "Aug-"$anAug.HotKeyNum;
        augName = ""$anAug.Class.Name;
        level = anAug.CurrentLevel;
        if (anAug.bBoosted){
            level = level-1;
        }

        augInfo = "{\"name\":\"" $ augName $"\",\"level\":"$level$"}";

        j = j $",\"" $ augId $ "\":" $ augInfo;


        anAug = anAug.next;
    }

}

static function BingoEventData(DXRando dxr, out string j)
{
    local PlayerDataItem data;
    local string event, desc;
    local int x, y, progress, max;
    local class<Json> js;
    js = class'Json';

    data = class'PlayerDataItem'.static.GiveItem(dxr.player);
    js.static.Add(j, "NumberOfBingos", data.NumberOfBingos());

    for(x=0; x<5; x++) {
        for(y=0; y<5; y++) {
            data.GetBingoSpot(x, y, event, desc, progress, max);
            j = j $ ",\"bingo-"$x$"-"$y $ "\":"
                $ "{\"event\":\"" $ event $ "\",\"desc\":\"" $ desc $ "\",\"progress\":" $ progress $ ",\"max\":" $ max $ "}";
        }
    }
}

static function GameTimeEventData(DXRando dxr, out string j)
{
    local int time, realtime, time_without_menus, i, t;
    local DXRStats stats;
    local class<Json> js;
    js = class'Json';

    stats = DXRStats(dxr.FindModule(class'DXRStats'));
    if(stats == None) return;

    for (i=1;i<=15;i++) {
        t = stats.GetMissionTime(i);
        js.static.Add(j, "mission-" $ i $ "-time", t);
        time += t;
        t = stats.GetCompleteMissionTime(i);
        js.static.Add(j, "mission-" $ i $ "-realtime", t);
        realtime += t;
        time_without_menus += t;
        t = stats.GetCompleteMissionMenuTime(i);
        js.static.Add(j, "mission-" $ i $ "-menutime", t);
        realtime += t;
    }
    js.static.Add(j, "time", time);
    js.static.Add(j, "timewithoutmenus", time_without_menus);
    js.static.Add(j, "realtime", realtime);
}

static function string GetLoadoutName(DXRando dxr)
{
    local DXRLoadouts loadout;
    loadout = DXRLoadouts(dxr.FindModule(class'DXRLoadouts'));
    if( loadout == None )
        return "";
    return loadout.GetName(loadout.loadout);
}

// BINGO STUFF
simulated function PlayerAnyEntry(#var(PlayerPawn) player)
{
    local PlayerDataItem data;
    local string event, desc;
    local int progress, max;

    data = class'PlayerDataItem'.static.GiveItem(player);

    //Update the exported bingo info in case this was a reload
    data.ExportBingoState();

    // don't overwrite existing bingo
    data.GetBingoSpot(0, 0, event, desc, progress, max);
    if( event != "" ) {
        //Make sure bingo didn't get completed just before leaving a level
        CheckBingoWin(dxr,data.NumberOfBingos());
    } else {
        SetGlobalSeed("bingo"$dxr.flags.bingoBoardRoll);
        _CreateBingoBoard(data, dxr.flags.settings.starting_map, dxr.flags.bingo_duration);
    }
}

simulated function CreateBingoBoard()
{
    local PlayerDataItem data;
    dxr.flags.bingoBoardRoll++;
    dxr.flags.SaveFlags();
    SetGlobalSeed("bingo"$dxr.flags.bingoBoardRoll);
    data = class'PlayerDataItem'.static.GiveItem(player());
    _CreateBingoBoard(data, dxr.flags.settings.starting_map, dxr.flags.bingo_duration);
}

simulated function _CreateBingoBoard(PlayerDataItem data, int starting_map, int bingo_duration, optional bool bTest)
{
    local int x, y, i;
    local string event, desc;
    local int progress, max, missions, starting_mission_mask, starting_mission, end_mission_mask, end_mission, maybe_mission_mask, masked_missions, maybe_masked_missions;
    local int options[ArrayCount(bingo_options)], num_options, slot, free_spaces;
    local bool bPossible;
    local float f;
    // local int testGoal;

    starting_mission = class'DXRStartMap'.static.GetStartMapMission(starting_map);
    starting_mission_mask = class'DXRStartMap'.static.GetStartingMissionMask(starting_map);
    maybe_mission_mask = class'DXRStartMap'.static.GetMaybeMissionMask(starting_map);
    if (bingo_duration!=0){
        end_mission = starting_mission + bingo_duration - 1; //The same mission is the first mission

        //Missions 7 and 13 don't exist, so don't count them
        if (starting_mission<7 && end_mission>=7){
            end_mission+=1;
        }
        if (starting_mission<13 && end_mission>=13){
            end_mission+=1;
        }
    } else {
        end_mission = 15;
    }
    end_mission_mask = class'DXRStartMap'.static.GetEndMissionMask(end_mission);

    num_options = 0;
    for(x=0; x<ArrayCount(bingo_options); x++) {
        if(bingo_options[x].event == "") continue;
        maybe_masked_missions = bingo_options[x].missions & maybe_mission_mask;
        masked_missions = bingo_options[x].missions & starting_mission_mask & end_mission_mask;
        if(maybe_masked_missions != 0 && masked_missions == 0) { // maybe?
            bPossible = class'DXRStartMap'.static.BingoGoalPossible(bingo_options[x].event,starting_map,end_mission);
            if(bTest) {
                l("Maybe BingoGoalPossible " $ bingo_options[x].event @ bPossible @ starting_map @ end_mission);
            }
            if(bPossible) {
                options[num_options++] = x;
                continue;
            }
        }
        if(bingo_options[x].missions!=0 && masked_missions == 0) continue;
        if(class'DXRStartMap'.static.BingoGoalImpossible(bingo_options[x].event,starting_map,end_mission)) {
            if(bTest) {
                l("BingoGoalImpossible " $ bingo_options[x].event @ starting_map @ end_mission);
            }
            continue;
        }
        options[num_options++] = x;
    }

    l("_CreateBingoBoard found " $ num_options $ " options, starting_map==" $ starting_map $ ", starting_mission==" $ starting_mission $ ", end_mission==" $ end_mission);
    if(bTest) {
        l("starting_mission == " $ starting_mission $ ", end_mission == " $ end_mission);
        l("starting_mission_mask == " $ starting_mission_mask $ ", end_mission_mask == " $ end_mission_mask $ ", maybe_mission_mask == " $ maybe_mission_mask);
        l( "#" $ starting_map @ class'DXRStartMap'.static.GetStartingMapNameCredits(starting_map) @ "(" $ bingo_duration @ end_mission $ ") " $ num_options $ " possible bingo goals" );
        for(x=0; x<num_options; x++) {
            i = options[x];
            l( "    " $ bingo_options[i].event $ "    - " $ bingo_options[i].desc );
        }
        test(num_options > 50, "_CreateBingoBoard more than 50 options, found " $ num_options $ " for " $ starting_map);
        l("----------------------------------");
        return;
    }

    for(x=0; x<ArrayCount(mutually_exclusive); x++) {
        if(mutually_exclusive[x].e1 == "") continue;

        slot = HandleMutualExclusion(mutually_exclusive[x], options, num_options);
        if( slot >= 0 ) {
            num_options--;
            options[slot] = options[num_options];
        }
    }

    l("_CreateBingoBoard have " $ num_options $ " options remaining after mutual exclusions");

    //Clear out the board so it is ready to be repopulated
    for(x=0; x<5; x++) {
        for(y=0; y<5; y++) {
            data.SetBingoSpot(x, y, "", "", 0, 0, 0);
        }
    }

    free_spaces = dxr.flags.settings.bingo_freespaces;
    free_spaces = self.Max(free_spaces, (25+3) - num_options);// +3 to ensure some variety of goal selection
    free_spaces = Min(free_spaces, 5); // max of 5 free spaces?

    //Prepopulate the board with free spaces
    switch(free_spaces) {
    case 5:// all fall through
        data.SetBingoSpot(1, 4, "Free Space", "Free Space", 1, 1, 0);// column
    case 4:
        data.SetBingoSpot(4, 1, "Free Space", "Free Space", 1, 1, 0);// row
    case 3:
        data.SetBingoSpot(3, 0, "Free Space", "Free Space", 1, 1, 0);// column
    case 2:
        data.SetBingoSpot(0, 3, "Free Space", "Free Space", 1, 1, 0);// row
    case 1:
        data.SetBingoSpot(2, 2, "Free Space", "Free Space", 1, 1, 0);// center
    case 0:
        break;
    }

    /* testGoal = some goal index;
    data.SetBingoSpot(
        0,
        0,
        bingo_options[testGoal].event,
        bingo_options[testGoal].desc,
        0,
        bingo_options[testGoal].max,
        bingo_options[testGoal].missions
    ); */

    for(x=0; x<5; x++) {
        for(y=0; y<5; y++) {
            data.GetBingoSpot(x,y,event,desc,progress,max);
            if(max > 0) { //Skip spaces that are already filled with something
                continue;
            }

            slot = rng(num_options);
            i = options[slot];
            event = bingo_options[i].event;
            desc = bingo_options[i].desc;
            desc = tweakBingoDescription(event,desc);
            missions = bingo_options[i].missions;
            masked_missions = missions & end_mission_mask; //Pre-mask the bingo endpoint
            max = bingo_options[i].max;
            // dynamic scaling based on starting mission (not current mission due to leaderboard exploits)
            if(max > 1 && InStr(desc, "%s") != -1) {
                f = float(dxr.flags.bingo_scale)/100.0;
                f = rngrange(f, 0.8, 1);// 80% to 100%
                f *= MissionsMaskAvailability(starting_mission, masked_missions) ** 1.5;
                max = Ceil(float(max) * f);
                max = self.Max(max, 1);
                desc = sprintf(desc, max);
            }

            num_options--;
            options[slot] = options[num_options];
            data.SetBingoSpot(x, y, event, desc, 0, max, missions);
        }
    }

    // TODO: we could handle bingo_freespaces>1 by randomly putting free spaces on the board, but this probably won't be a desired feature
    data.ExportBingoState();
}

simulated function int HandleMutualExclusion(MutualExclusion m, int options[ArrayCount(bingo_options)], int num_options) {
    local int a, b, overwrite;

    for(a=0; a<num_options; a++) {
        if( bingo_options[options[a]].event == m.e1 ) break;
    }
    if( a >= num_options ) return -1;

    for(b=0; b<num_options; b++) {
        if( bingo_options[options[b]].event == m.e2 ) break;
    }
    if( b >= num_options ) return -1;

    if(rngb()) {
        return a;
    } else {
        return b;
    }
}

function bool CheckBingoWin(DXRando dxr, int numBingos)
{
    //Block this in HX for now
    if(#defined(hx)) return false;

    if (dxr.flags.settings.bingo_win > 0){
        if (numBingos >= dxr.flags.settings.bingo_win && dxr.LocalURL!="ENDGAME4" && dxr.LocalURL!="ENDGAME4REV"){
            info("Number of bingos: "$numBingos$" has exceeded the bingo win threshold! "$dxr.flags.settings.bingo_win);
            bingo_win_countdown = 5;
            BingoWinScreen();
            return true;
        }
    }
    return false;
}

function _MarkBingo(coerce string eventname)
{
    local int previousbingos, nowbingos, time;
    local PlayerDataItem data;
    local string j;
    local class<Json> js;
    js = class'Json';

    // combine some events
    eventname=RemapBingoEvent(eventname);

    //Remapping can also block an event from being marked
    if (eventname==""){
        return;
    }

    data = class'PlayerDataItem'.static.GiveItem(player());

    previousbingos = data.NumberOfBingos();
    l(self$"._MarkBingo("$eventname$") data: "$data$", previousbingos: "$previousbingos);

    if( ! data.IncrementBingoProgress(eventname)) return;

    nowbingos = data.NumberOfBingos();
    l(self$"._MarkBingo("$eventname$") previousbingos: "$previousbingos$", nowbingos: "$nowbingos);

    if( nowbingos > previousbingos ) {
        time = class'DXRStats'.static.GetTotalTime(dxr);
        player().ClientMessage("That's a bingo! Game time: " $ class'DXRStats'.static.fmtTimeToString(time),, true);

        j = js.static.Start("Bingo");
        js.static.Add(j, "newevent", eventname);
        js.static.Add(j, "location", vectclean(player().Location));
        GeneralEventData(dxr, j);
        BingoEventData(dxr, j);
        GameTimeEventData(dxr, j);
        js.static.End(j);

        class'DXRTelemetry'.static.SendEvent(dxr, player(), j);

        CheckBingoWin(dxr,nowbingos);
    } else {
        player().ClientMessage("Completed bingo goal: " $ data.GetBingoDescription(eventname));
    }
}

static function MarkBingo(DXRando dxr, coerce string eventname)
{
    local DXREvents e;
    e = DXREvents(dxr.FindModule(class'DXREvents'));
    log(e$".MarkBingo "$dxr$", "$eventname);
    if(e != None) {
        e._MarkBingo(eventname);
    }
}

function _MarkBingoAsFailed(coerce string eventname)
{
    local PlayerDataItem data;

    // TODO: call RemapBingoEvent if it ever loses its side effects
    /* eventname=RemapBingoEvent(eventname);
    if (eventname==""){
        return;
    } */

    data = class'PlayerDataItem'.static.GiveItem(player());
    l(self$"._MarkBingoAsFailed("$eventname$") data: "$data);
    if (data.MarkBingoAsFailed(eventname)) {
        player().ClientMessage("Failed bingo goal: " $ data.GetBingoDescription(eventname));
    }
}

static function MarkBingoAsFailed(DXRando dxr, coerce string eventname)
{
    local DXREvents e;
    e = DXREvents(dxr.FindModule(class'DXREvents'));
    log(e$".MarkBingoAsFailed "$dxr$", "$eventname);
    if (e != None) {
        e._MarkBingoAsFailed(eventname);
    }
}

function bool _IsBingoFailed(coerce string eventname)
{
    local PlayerDataItem data;
    data = class'PlayerDataItem'.static.GiveItem(player());
    return data.IsBingoFailed(eventname);
}

static function bool IsBingoFailed(DXRando dxr, coerce string eventname)
{
    local DXREvents e;
    e = DXREvents(dxr.FindModule(class'DXREvents'));
    if (e != None) {
        return e._IsBingoFailed(eventname);
    }
    return false;
}

function AddBingoScreen(CreditsWindow cw)
{
    local CreditsBingoWindow cbw;
    cbw = CreditsBingoWindow(cw.winScroll.NewChild(Class'CreditsBingoWindow'));
    cbw.FillBingoWindow(player());
}

function AddDXRCredits(CreditsWindow cw)
{
    cw.PrintLn();
    cw.PrintHeader("Bingo");
    AddBingoScreen(cw);
    cw.PrintLn();
}

static function int BingoActiveMission(int currentMission, int missionsMask)
{
    local int missionAnded, minMission;
    if(missionsMask == 0) return 1;// 1==maybe
    missionAnded = (1 << currentMission) & missionsMask;
    if(missionAnded != 0) return 2;// 2==true
    minMission = currentMission;

#ifdef backtracking
    // check conjoined backtracking missions
    switch(currentMission) {
    case 10:
        currentMission=11;
        break;
    case 11:
        currentMission=10;
        minMission=10;
        break;
    case 12:
        currentMission=14;
        break;
    case 14:
        currentMission=12;
        minMission=12;
        break;
    }
    missionAnded = (1 << currentMission) & missionsMask;
    if(missionAnded != 0) return 2;// 2==true
#endif

    if(missionsMask < (1<<minMission)) {
        return -1;// impossible in future missions
    }

    return 0;// 0==false
}

static function float MissionsMaskAvailability(int currentMission, int missionsMask)
{
    local int num, expired, i, t;

    if(missionsMask == 0) return 1.0 - float(currentMission-1) / 15.0;

    for(i=1; i<currentMission; i++) {
        t = (1<<i) & missionsMask;
        expired += int( t != 0 );
    }
    for(i=currentMission; i<=15; i++) {
        t = (1<<i) & missionsMask;
        num += int( t != 0 );
    }

    return float(num)/float(expired+num);
}

function RunTests()
{
    testint(NumBitsSet(0), 0, "NumBitsSet");
    testint(NumBitsSet(1), 1, "NumBitsSet");
    testint(NumBitsSet(2), 1, "NumBitsSet");
    testint(NumBitsSet(3), 2, "NumBitsSet");

    testint(NumBitsSet(1<<15), 1, "NumBitsSet");
    testint(NumBitsSet((1<<15)+(1<<8)), 2, "NumBitsSet");

    testfloat(MissionsMaskAvailability(1, (1<<3)), 1, "MissionsMaskAvailability");
    testfloat(MissionsMaskAvailability(5, (1<<5)), 1, "MissionsMaskAvailability");
    testfloat(MissionsMaskAvailability(5, (1<<8)), 1, "MissionsMaskAvailability");

    testfloat(MissionsMaskAvailability(5, (1<<3)+(1<<5)), 0.5, "MissionsMaskAvailability");
    testfloat(MissionsMaskAvailability(5, (1<<3)+(1<<7)), 0.5, "MissionsMaskAvailability");
    testfloat(MissionsMaskAvailability(5, (1<<3)+(1<<7)+(1<<10)), 2/3, "MissionsMaskAvailability");

    testfloat(MissionsMaskAvailability(1, 0), 1, "MissionsMaskAvailability");
    testfloat(MissionsMaskAvailability(6, 0), 10/15, "MissionsMaskAvailability");
    testfloat(MissionsMaskAvailability(15, 0), 1/15, "MissionsMaskAvailability");

    testint(BingoActiveMission(1, 0), 1, "BingoActiveMission maybe");
    testint(BingoActiveMission(1, (1<<1)), 2, "BingoActiveMission");
    testint(BingoActiveMission(2, (1<<1)), -1, "BingoActiveMission too late");
    testint(BingoActiveMission(15, (1<<15)), 2, "BingoActiveMission");
    testint(BingoActiveMission(3, (1<<15)), 0, "BingoActiveMission false");
}

function ExtendedTests()
{
    local int i;
    local string mapName, friendlyName;

    for(i=0; i<160; i++) {
        mapName = class'DXRStartMap'.static._GetStartMap(i, friendlyName);
        if(friendlyName == "") continue;
        l( "#" $ i @ friendlyName @ mapName $ " bingo goals test:" );
        _CreateBingoBoard(None, i, 1, true);
    }
}

defaultproperties
{
    bingo_win_countdown=-1
}
