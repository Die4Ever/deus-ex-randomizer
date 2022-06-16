class DXREvents extends DXRActorsBase;

var bool died;
var name watchflags[32];
var int num_watchflags;

struct BingoOption {
    var string event, desc;
    var int max;
};
var BingoOption bingo_options[100];

struct MutualExclusion {
    var string e1, e2;
};
var MutualExclusion mutually_exclusive[20];

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
    local Mutt starr;// arms smuggler's dog in Paris

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
        WatchFlag('MS_DL_Played');// this is the datalink played after dealing with the hostage situation, from Mission02.uc

        foreach AllActors(class'ChildMale', child) {
            if(child.BindName == "Josh" || child.BindName == "Billy")
                child.bImportant = true;
        }

        foreach AllActors(class'MapExit',m,'Boat_Exit'){
            m.Tag = 'Boat_Exit2';
        }
        Tag = 'Boat_Exit';
        break;
    case "02_NYC_HOTEL":
        WatchFlag('M02HostagesRescued');// for the hotel, set by Mission02.uc
        break;
    case "02_NYC_UNDERGROUND":
        WatchFlag('FordSchickRescued');
        break;
    case "02_NYC_BAR":
        WatchFlag('JockSecondStory');
        break;
    case "02_NYC_FREECLINIC":
        WatchFlag('BoughtClinicPlan');
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
        Tag = 'MadeBasket';
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
    case "10_PARIS_CATACOMBS_TUNNELS":
        WatchFlag('SilhouetteHostagesAllRescued');
        break;
    case "10_PARIS_METRO":
        WatchFlag('M10EnteredBakery');
        WatchFlag('AlleyCopSeesPlayer_Played');
        WatchFlag('assassinapartment');

        foreach AllActors(class'GuntherHermann', gunther) {
            gunther.bInvincible = false;
        }
        foreach AllActors(class'Mutt', starr) {
            starr.bImportant = true;// you're important to me
            starr.BindName = "Starr";
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
    } else if( ! #defined(vanilla)) {
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

    l("SendFlagEvent " $ eventname @ immediate);

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
    js.static.Add(j, "location", dxr.player.location);
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

    foreach victim.AllActors(class'DXRando', dxr) break;

    MarkBingo(dxr, victim.BindName$"_Dead");
    if(!victim.bImportant)
        return;

    if(victim.BindName == "PaulDenton")
        dxr.flagbase.SetBool('DXREvents_PaulDead', true,, 999);

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
    js.static.Add(j, "location", dxr.player.location);
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
    js.static.Add(j, "maxrando", dxr.flags.maxrando);
    GeneralEventData(dxr, j);
    BingoEventData(dxr, j);
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

    // don't overwrite existing bingo
    data.GetBingoSpot(0, 0, event, desc, progress, max);
    if( event != "" ) return;
    SetGlobalSeed("bingo");
    _CreateBingoBoard(data);
}

simulated function CreateBingoBoard()
{
    local PlayerDataItem data;
    SetGlobalSeed("bingo"$FRand());
    data = class'PlayerDataItem'.static.GiveItem(player());
    _CreateBingoBoard(data);
}

simulated function _CreateBingoBoard(PlayerDataItem data)
{
    local int x, y;
    local string event, desc;
    local int progress, max;
    local int options[100], num_options, slot;

    num_options = 0;
    for(x=0; x<ArrayCount(bingo_options); x++) {
        if(bingo_options[x].event == "") continue;
        options[num_options++] = x;
    }

    for(x=0; x<ArrayCount(mutually_exclusive); x++) {
        if(mutually_exclusive[x].e1 == "") continue;

        slot = HandleMutualExclusion(mutually_exclusive[x], options, num_options);
        if( slot >= 0 ) {
            num_options--;
            options[slot] = options[num_options];
        }
    }

    for(x=0; x<5; x++) {
        for(y=0; y<5; y++) {
            if(num_options == 0 || (x==2 && y==2)) {
                data.SetBingoSpot(x, y, "Free Space", "Free Space", 1, 1);
                continue;
            }

            slot = rng(num_options);
            event = bingo_options[options[slot]].event;
            desc = bingo_options[options[slot]].desc;
            max = bingo_options[options[slot]].max;
            num_options--;
            options[slot] = options[num_options];
            data.SetBingoSpot(x, y, event, desc, 0, max);
        }
    }
}

simulated function int HandleMutualExclusion(MutualExclusion m, int options[100], int num_options) {
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

function _MarkBingo(coerce string eventname)
{
    local int previousbingos, nowbingos, time;
    local PlayerDataItem data;
    local string j;
    local class<Json> js;
    js = class'Json';

    // combine some events
    switch(eventname) {
        case "ManBathroomBarks_Played":
            eventname = "BathroomBarks_Played";// LDDP
            break;
        case "hostage_female_Dead":
        case "hostage_Dead":
            eventname = "paris_hostage_Dead";
            break;
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
        js.static.Add(j, "location", player().Location);
        js.static.add(j, "time", time);
        GeneralEventData(dxr, j);
        BingoEventData(dxr, j);
        js.static.End(j);

        class'DXRTelemetry'.static.SendEvent(dxr, player(), j);
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

defaultproperties
{
    bingo_options(0)=(event="TerroristCommander_Dead",desc="Kill the Terrorist Commander",max=1)
	bingo_options(1)=(event="TiffanySavage_Dead",desc="Kill Tiffany Savage",max=1)
	bingo_options(2)=(event="PaulDenton_Dead",desc="Let Paul die",max=1)
	bingo_options(3)=(event="JordanShea_Dead",desc="Kill Jordan Shea",max=1)
	bingo_options(4)=(event="SandraRenton_Dead",desc="Kill Sandra Renton",max=1)
	bingo_options(5)=(event="GilbertRenton_Dead",desc="Kill Gilbert Renton",max=1)
	bingo_options(6)=(event="AnnaNavarre_Dead",desc="Kill Anna Navarre",max=1)
	bingo_options(7)=(event="GuntherHermann_Dead",desc="Kill Gunther Hermann",max=1)
	bingo_options(8)=(event="JoJoFine_Dead",desc="Kill JoJo",max=1)
	bingo_options(9)=(event="TobyAtanwe_Dead",desc="Kill Toby Atanwe",max=1)
	bingo_options(10)=(event="Antoine_Dead",desc="Kill Antoine",max=1)
	bingo_options(11)=(event="Chad_Dead",desc="Kill Chad",max=1)
	bingo_options(12)=(event="paris_hostage_Dead",desc="Kill both the hostages in the catacombs",max=2)
	//bingo_options(13)=(event="hostage_female_Dead",desc="Kill hostage Anna",max=1)
	bingo_options(14)=(event="Hela_Dead",desc="Kill Hela",max=1)
	bingo_options(15)=(event="Renault_Dead",desc="Kill Renault",max=1)
	bingo_options(16)=(event="Labrat_Bum_Dead",desc="Kill Labrat Bum",max=1)
	bingo_options(17)=(event="DXRNPCs1_Dead",desc="Kill The Merchant",max=1)
	bingo_options(18)=(event="lemerchant_Dead",desc="Kill Le Merchant",max=1)
	bingo_options(19)=(event="Harold_Dead",desc="Kill Harold the mechanic in the hanger",max=1)
	//bingo_options()=(event="Josh_Dead",desc="Kill Josh",max=1)
	//bingo_options()=(event="Billy_Dead",desc="Kill Billy",max=1)
	//bingo_options()=(event="MarketKid_Dead",desc="Kill Louis Pan",max=1)
	bingo_options(20)=(event="aimee_Dead",desc="Kill Aimee",max=1)
	bingo_options(21)=(event="WaltonSimons_Dead",desc="Kill Walton Simons",max=1)
	bingo_options(22)=(event="JoeGreene_Dead",desc="Kill Joe Greene",max=1)
    bingo_options(23)=(event="GuntherFreed",desc="Free Gunther from jail",max=1)
    bingo_options(24)=(event="BathroomBarks_Played",desc="Embarass UNATCO",max=1)
    //bingo_options(25)=(event="ManBathroomBarks_Played",desc="Embarass UNATCO",max=1)
    bingo_options(26)=(event="GotHelicopterInfo",desc="A bomb!",max=1)
    bingo_options(27)=(event="JoshFed",desc="Give Josh some food",max=1)
    bingo_options(28)=(event="M02BillyDone",desc="Give Billy some food",max=1)
    bingo_options(29)=(event="FordSchickRescued",desc="Rescue Ford Schick",max=1)
    bingo_options(30)=(event="NiceTerrorist_Dead",desc="Ignore Paul in the 747 Hanger",max=1)
    bingo_options(31)=(event="M10EnteredBakery",desc="Enter the bakery",max=1)
    //bingo_options()=(event="AlleyCopSeesPlayer_Played",desc="",max=1)
    bingo_options(32)=(event="FreshWaterOpened",desc="Fix the water",max=1)
    bingo_options(33)=(event="assassinapartment",desc="Visit Starr in Paris",max=1)
    bingo_options(34)=(event="GaveRentonGun",desc="Give Gilbert a weapon",max=1)
    bingo_options(35)=(event="DXREvents_LeftOnBoat",desc="Take the boat out of Battery Park",max=1)
    bingo_options(36)=(event="AlleyBumRescued",desc="Rescue the alley bum",max=1)
    bingo_options(37)=(event="FoundScientistBody",desc="Search the canal",max=1)
    bingo_options(38)=(event="ClubMercedesConvo1_Done",desc="Help Mercedes and Tessa",max=1)
    bingo_options(39)=(event="M08WarnedSmuggler",desc="Warn Smuggler",max=1)
    bingo_options(40)=(event="ShipPowerCut",desc="Help the electrician",max=1)
    bingo_options(41)=(event="CamilleConvosDone",desc="Get info from Camille",max=1)
    bingo_options(42)=(event="MeetAI4_Played",desc="Talk to Morpheus",max=1)
    bingo_options(43)=(event="DL_Flooded_Played",desc="Check flooded zone in the ocean lab",max=1)
    bingo_options(44)=(event="JockSecondStory",desc="Get Jock buzzed",max=1)
    bingo_options(45)=(event="M07ChenSecondGive_Played",desc="Party with the Triads",max=1)
    bingo_options(46)=(event="DeBeersDead",desc="Put Lucius out of his misery",max=1)
    bingo_options(47)=(event="StantonAmbushDefeated",desc="Defend Dowd from the ambush",max=1)
    bingo_options(48)=(event="SmugglerDied",desc="Let Smuggler die",max=1)
    bingo_options(49)=(event="GaveDowdAmbrosia",desc="Give Dowd Ambrosia",max=1)
    bingo_options(50)=(event="JockBlewUp",desc="Let Jock die",max=1)
    bingo_options(51)=(event="SavedPaul",desc="Save Paul",max=1)
    bingo_options(52)=(event="nsfwander",desc="Save Miguel",max=1)
    bingo_options(53)=(event="MadeBasket",desc="Sign up for the Knicks",max=1)
    bingo_options(54)=(event="BoughtClinicPlan",desc="Buy the full treatment plan in the clinic",max=1)
    bingo_options(55)=(event="ExtinguishFire",desc="Extinguish yourself with running water",max=1)
    bingo_options(56)=(event="SubwayHostagesSaved",desc="Save both hostages in the subway",max=1)
    bingo_options(57)=(event="HotelHostagesSaved",desc="Save all 3 hostages in the hotel",max=1)
    bingo_options(58)=(event="SilhouetteHostagesAllRescued",desc="Save both hostages in the catacombs",max=1)
    bingo_options(59)=(event="JosephManderley_Dead",desc="Kill Joseph Manderley",max=1)

    mutually_exclusive(0)=(e1="PaulDenton_Dead",e2="SavedPaul")
    mutually_exclusive(1)=(e1="JockBlewUp",e2="GotHelicopterInfo")
    mutually_exclusive(2)=(e1="SmugglerDied",e2="M08WarnedSmuggler")
    mutually_exclusive(3)=(e1="SilhouetteHostagesAllRescued",e2="paris_hostage_Dead")
}
