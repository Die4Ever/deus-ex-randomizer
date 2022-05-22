class DXREvents extends DXRActorsBase;

var bool died;
var name watchflags[32];
var int num_watchflags;

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


function SetWatchFlags() {
    local MapExit m;
    local ChildMale child;
    local Mechanic mechanic;
    local JunkieFemale jf;
    local GuntherHermann gunther;

    switch(dxr.localURL) {
    case "01_NYC_UNATCOISLAND":
        WatchFlag('GuntherFreed');
        WatchFlag('GuntherRespectsPlayer');
        break;
    case "01_NYC_UNATCOHQ":
        WatchFlag('BathroomBarks_Played');
        WatchFlag('ManBathroomBarks_Played');
        break;
    case "02_NYC_BATTERYPARK":
        WatchFlag('JoshFed');
        WatchFlag('M02BillyDone');

        foreach AllActors(class'ChildMale', child) {
            if(child.BindName == "Josh" || child.BindName == "Billy")
                child.bImportant = true;
        }

        foreach AllActors(class'MapExit',m,'Boat_Exit'){
            m.Tag = 'Boat_Exit2';
        }
        Tag = 'Boat_Exit';
        break;
    case "02_NYC_UNDERGROUND":
        WatchFlag('FordSchickRescued');
        break;
    case "02_NYC_BAR":
        WatchFlag('JockSecondStory');
        break;
    case "03_NYC_UNATCOISLAND":
        WatchFlag('DXREvents_LeftOnBoat');
        break;
    case "03_NYC_BROOKLYNBRIDGESTATION":
        WatchFlag('FreshWaterOpened');
        break;
    case "03_NYC_HANGAR":
        WatchFlag('NiceTerrorist_Dead');// only tweet it once, not like normal PawnDeaths

        foreach AllActors(class'Mechanic', mechanic) {
            if(mechanic.BindName == "Harold")
                mechanic.bImportant = true;
        }
        break;
    case "04_NYC_HOTEL":
        WatchFlag('GaveRentonGun');
        break;
    case "05_NYC_UNATCOISLAND":
        Tag = 'nsfwander';// saved Miguel
        break;
    case "02_NYC_STREET":
        WatchFlag('AlleyBumRescued');
    case "04_NYC_STREET":
    case "08_NYC_STREET":
        Tag = 'MadeBasket';
        break;
    case "05_NYC_UNATCOMJ12LAB":
        CheckPaul();
        break;
    case "06_HONGKONG_WANCHAI_CANAL":
        WatchFlag('FoundScientistBody');
        break;
    case "06_HONGKONG_WANCHAI_UNDERWORLD":
        WatchFlag('ClubMercedesConvo1_Done');
        WatchFlag('M07ChenSecondGive_Played');
        break;
    case "08_NYC_STREET":
        WatchFlag('StantonAmbushDefeated');
        break;
    case "08_NYC_SMUG":
        WatchFlag('M08WarnedSmuggler');
        break;
    case "09_NYC_SHIP":
        ReportMissingFlag('M08WarnedSmuggler', "SmugglerDied");
        break;
    case "09_NYC_SHIPBELOW":
        WatchFlag('ShipPowerCut');// sparks of electricity come off that thing like lightning!
        break;
    case "09_NYC_GRAVEYARD":
        WatchFlag('GaveDowdAmbrosia');
        break;
    case "10_PARIS_CATACOMBS":
        foreach AllActors(class'JunkieFemale', jf) {
            if(jf.BindName == "aimee")
                jf.bImportant = true;
        }
        break;
    case "10_PARIS_METRO":
        WatchFlag('M10EnteredBakery');
        WatchFlag('AlleyCopSeesPlayer_Played');
        WatchFlag('assassinapartment');

        foreach AllActors(class'GuntherHermann', gunther) {
            gunther.bInvincible = false;
        }
        break;
    case "10_PARIS_CLUB":
        WatchFlag('CamilleConvosDone');
        break;
    case "11_PARIS_EVERETT":
        WatchFlag('GotHelicopterInfo');
        WatchFlag('MeetAI4_Played');
        WatchFlag('DeBeersDead');
        break;
    case "14_OCEANLAB_LAB":
        WatchFlag('DL_Flooded_Played');
        break;
    case "15_AREA51_BUNKER":
        WatchFlag('JockBlewUp');
        break;
    }
}

function CheckPaul() {
    if( dxr.flagbase.GetBool('PaulDenton_Dead') ) {
        if( ! dxr.flagbase.GetBool('DXREvents_PaulDead'))
            PaulDied(dxr);
    } else if( ! #defined vanilla ) {
        SavedPaul(dxr, dxr.player);
    }
}

function WatchFlag(name flag) {
    if( dxr.flagbase.GetBool(flag) ) {
        SendFlagEvent(flag, true);
        return;
    }
    watchflags[num_watchflags++] = flag;
    if(num_watchflags > ArrayCount(watchflags))
        err("WatchFlag num_watchflags > ArrayCount(watchflags)");
}

function ReportMissingFlag(name flag, string eventname) {
    if( ! dxr.flagbase.GetBool(flag) ) {
        SendFlagEvent(eventname, true);
    }
}

function Ending_FirstEntry()
{
    local int ending,time;

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
        //The dance party won't actually get hit since the rando can't run there at the moment
        case "ENDGAME4": //Dance party
            ending = 4;
            break;
        default:
            //In case rando runs some player level or something with mission 99
            break;
    }

    if (ending!=0){
        //Notify of game completion with correct ending number
        time = class'DXRStats'.static.GetTotalTime(dxr);
        BeatGame(dxr,ending,time);
    }
}

simulated function AnyEntry()
{
    Super.AnyEntry();
    SetTimer(1, true);
}

simulated function PlayerAnyEntry(#var PlayerPawn  player)
{
    local PlayerDataItem data;
    local int x, y;

    SetGlobalSeed("bingo");
    data = class'PlayerDataItem'.static.GiveItem(player);

    for(x=0; x<5; x++) {
        for(y=0; y<5; y++) {
            if(x==2 && y==2) {
                data.SetBingoSpot(x, y, "free space", "free space", 1, 1);
            }
            else {
                data.SetBingoSpot(x, y, "TerroristCommander_Dead", "TerroristCommander_Dead", 0, 1);
            }
        }
    }
}

simulated function Timer()
{
    local int i;
    for(i=0; i<num_watchflags; i++) {
        if(watchflags[i] == '') break;
        if( dxr.flagbase.GetBool(watchflags[i]) ) {
            SendFlagEvent(watchflags[i]);
            num_watchflags--;
            watchflags[i] = watchflags[num_watchflags];
            i--;
        }
    }
    // for nonvanilla, because GameInfo.Died is called before the player's Dying state calls root.ClearWindowStack();
    if(died) {
        class'DXRHints'.static.AddDeath(dxr, player());
        died = false;
    }
}

function bool SpecialTriggerHandling(Actor Other, Pawn Instigator)
{
    local MapExit m;

    if (tag == 'Boat_Exit'){
        dxr.flagbase.SetBool('DXREvents_LeftOnBoat', true,, 999);

        foreach AllActors(class'MapExit',m,'Boat_Exit2'){
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
    js = class'Json';

    Super.Trigger(Other, Instigator);
    l("Trigger("$Other$", "$instigator$")");

    if (!SpecialTriggerHandling(Other,Instigator)){
        j = js.static.Start("Trigger");
        js.static.Add(j, "instigator", GetActorName(Instigator));
        js.static.Add(j, "tag", tag);
        js.static.add(j, "other", GetActorName(other));
        GeneralEventData(dxr, j);
        js.static.End(j);

        class'DXRTelemetry'.static.SendEvent(dxr, Instigator, j);
        _MarkBingo(tag);
    }
}

function SendFlagEvent(coerce string eventname, optional bool immediate)
{
    local string j;
    local class<Json> js;
    js = class'Json';

    j = js.static.Start("Flag");
    js.static.Add(j, "flag", eventname);
    js.static.Add(j, "immediate", immediate);
    js.static.Add(j, "location", dxr.player.location);
    GeneralEventData(dxr, j);
    js.static.End(j);

    class'DXRTelemetry'.static.SendEvent(dxr, dxr.player, j);
    _MarkBingo(eventname);
}

static function _DeathEvent(DXRando dxr, Actor victim, Actor Killer, coerce string damageType, vector HitLocation, string type)
{
    local string j;
    local class<Json> js;
    js = class'Json';

    j = js.static.Start(type);
    js.static.Add(j, "victim", GetActorName(victim));
    js.static.Add(j, "victimBindName", victim.BindName);
    js.static.Add(j, "victimRandomizedName", GetRandomizedName(victim));

    if(Killer != None) {
        js.static.Add(j, "killerclass", Killer.Class.Name);
        js.static.Add(j, "killer", GetActorName(Killer));
        js.static.Add(j, "killerRandomizedName", GetRandomizedName(Killer));
    }
    js.static.Add(j, "dmgtype", damageType);
    GeneralEventData(dxr, j);
    js.static.Add(j, "location", victim.Location);
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

static function AddPlayerDeath(DXRando dxr, #var PlayerPawn  player, optional Actor Killer, optional coerce string damageType, optional vector HitLocation)
{
    local DXREvents ev;
    class'DXRStats'.static.AddDeath(player);

    if(#defined injections)
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
        if( !IsHuman(Killer) && Robot(Killer) == None ) {
            // only humans and robots can shoot? karkians deal shot damage
            damageType = "";
        }
    }

    _DeathEvent(dxr, player, Killer, damageType, HitLocation, "DEATH");
}

static function AddPawnDeath(ScriptedPawn victim, optional Actor Killer, optional coerce string damageType, optional vector HitLocation)
{
    local DXRando dxr;
    if(!victim.bImportant)
        return;

    foreach victim.AllActors(class'DXRando', dxr) break;

    if(victim.BindName == "PaulDenton")
        dxr.flagbase.SetBool('DXREvents_PaulDead', true,, 999);

    _DeathEvent(dxr, victim, Killer, damageType, HitLocation, "PawnDeath");
    MarkBingo(dxr, victim.BindName$"_Dead");
}

static function AddDeath(Pawn victim, optional Actor Killer, optional coerce string damageType, optional vector HitLocation)
{
    local DXRando dxr;
    local #var PlayerPawn  player;
    local #var prefix ScriptedPawn sp;
    player = #var PlayerPawn (victim);
    sp = #var prefix ScriptedPawn(victim);
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
    js.static.Add(j, "dmgtype", "");
    GeneralEventData(dxr, j);
    js.static.Add(j, "location", dxr.player.location);
    js.static.End(j);
    dxr.flagbase.SetBool('DXREvents_PaulDead', true,, 999);
    class'DXRTelemetry'.static.SendEvent(dxr, dxr.player, j);
    MarkBingo(dxr, "PaulDenton_Dead");
}

static function SavedPaul(DXRando dxr, #var PlayerPawn  player, optional int health)
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

static function BeatGame(DXRando dxr, int ending, int time)
{
    local string j;
    local class<Json> js;
    js = class'Json';

    j = js.static.Start("BeatGame");
    js.static.Add(j, "ending", ending);
    js.static.Add(j, "time", time);
    js.static.Add(j, "SaveCount", dxr.player.saveCount);
    js.static.Add(j, "deaths", class'DXRStats'.static.GetDataStorageStat(dxr, 'DXRStats_deaths'));
    GeneralEventData(dxr, j);
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
    js.static.Add(j, "location", player.Location);
    GeneralEventData(dxr, j);
    js.static.End(j);

    class'DXRTelemetry'.static.SendEvent(dxr, dxr.player, j);
    MarkBingo(dxr, "ExtinguishFire");
}

static function GeneralEventData(DXRando dxr, out string j)
{
    local string loadout;
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
}

static function string GetLoadoutName(DXRando dxr)
{
    local DXRLoadouts loadout;
    loadout = DXRLoadouts(dxr.FindModule(class'DXRLoadouts'));
    if( loadout == None )
        return "";
    return loadout.GetName(loadout.loadout);
}

function _MarkBingo(coerce string eventname)
{
    local int previousbingos;
    local PlayerDataItem data;

    data = class'PlayerDataItem'.static.GiveItem(player());
    previousbingos = data.NumberOfBingos();

    if( ! data.IncrementBingoProgress(eventname)) return;

    if( data.NumberOfBingos() > previousbingos ) {
        player().ClientMessage("That's a bingo!");
    }
}

static function MarkBingo(DXRando dxr, coerce string eventname)
{
    local DXREvents e;
    e = DXREvents(dxr.FindModule(class'DXREvents'));
    if(e != None) {
        e._MarkBingo(eventname);
    }
}
