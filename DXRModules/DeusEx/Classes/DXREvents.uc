class DXREvents extends DXRActorsBase;

var transient #var PlayerPawn  _player;
var transient bool died;

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
    switch(dxr.localURL) {
    case "01_NYC_UNATCOISLAND":
        WatchDeath('TerroristCommander_Dead');
        break;
    case "01_NYC_UNATCOHQ":
        WatchFlag('BathroomBarks_Played');
        WatchFlag('ManBathroomBarks_Played');
        break;
    case "02_NYC_BATTERYPARK":
        WatchFlag('JoshFed');
        WatchFlag('M02BillyDone');
        break;
    case "02_NYC_UNDERGROUND":
        WatchFlag('FordSchickRescued');
        break;
    case "03_NYC_BROOKLYNBRIDGESTATION":
        WatchFlag('FreshWaterOpened');
        break;
    case "04_NYC_HOTEL":
        WatchFlag('GaveRentonGun');
        break;
    case "05_NYC_UNATCOISLAND":
        WatchFlag('MiguelHack_Played');
        break;
    case "02_NYC_STREET":
    case "04_NYC_STREET":
    case "08_NYC_STREET":
        Tag = 'MadeBasket';
        break;

    case "05_NYC_UNATCOMJ12LAB":
        CheckPaul();
        break;
    case "10_PARIS_METRO":
        WatchFlag('M10EnteredBakery');
        WatchFlag('AlleyCopSeesPlayer_Played');
        WatchFlag('assassinapartment');
        break;
    case "11_PARIS_EVERETT":
        WatchFlag('GotHelicopterInfo');
        break;
    case "12_VANDENBERG_GAS":
        WatchDeath('TiffanySavage_Dead');
        break;
    }
}

function CheckPaul() {
    if( dxr.flagbase.GetBool('PaulDenton_Dead') && ! dxr.flagbase.GetBool('DXREvents_PaulDead') ) {
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

function WatchDeath(name flag) {
    if( !#defined injections )
        WatchFlag(flag);
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

simulated function PlayerRespawn(#var PlayerPawn  player)
{
    Super.PlayerRespawn(player);
    _player = player;
    died = false;
    SetTimer(1, true);
}

simulated function PlayerAnyEntry(#var PlayerPawn  player)
{
    Super.PlayerAnyEntry(player);
    _player = player;
    died = false;
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
    if( !#defined injections && _player != None && _player.IsInState('Dying') && !died) {
        died = true;
        AddDeath(dxr, _player);
    }
}

function Trigger(Actor Other, Pawn Instigator)
{
     local string j;
    local class<Json> js;
    js = class'Json';

    Super.Trigger(Other, Instigator);
    l("Trigger("$Other$", "$instigator$")");

    j = js.static.Start("Trigger");
    js.static.Add(j, "instigator", GetActorName(Instigator));
    js.static.Add(j, "tag", tag);
    js.static.add(j, "other", GetActorName(other));
    GeneralEventData(dxr, j);
    js.static.End(j);

    class'DXRTelemetry'.static.SendEvent(dxr, Instigator, j);
}

function SendFlagEvent(name flag, optional bool immediate)
{
    local string j;
    local class<Json> js;
    js = class'Json';

    j = js.static.Start("Flag");
    js.static.Add(j, "flag", flag);
    js.static.Add(j, "immediate", immediate);
    js.static.Add(j, "location", dxr.player.location);
    GeneralEventData(dxr, j);
    js.static.End(j);

    class'DXRTelemetry'.static.SendEvent(dxr, dxr.player, j);
}

static function _DeathEvent(DXRando dxr, Actor victim, Actor Killer, coerce string damageType, vector HitLocation, string type)
{
    local string j;
    local class<Json> js;
    js = class'Json';

    j = js.static.Start(type);
    js.static.Add(j, "victim", GetActorName(victim));
    js.static.Add(j, "victimBindName", victim.BindName);
    if(Killer != None) {
        js.static.Add(j, "killerclass", Killer.Class.Name);
        js.static.Add(j, "killer", GetActorName(Killer));
    }
    js.static.Add(j, "dmgtype", damageType);
    GeneralEventData(dxr, j);
    js.static.Add(j, "location", victim.Location);
    js.static.End(j);
    class'DXRTelemetry'.static.SendEvent(dxr, victim, j);
}

static function AddDeath(DXRando dxr, #var PlayerPawn  player, optional Actor Killer, optional coerce string damageType, optional vector HitLocation)
{
    class'DXRStats'.static.AddDeath(player);
    class'DXRHints'.static.AddDeath(dxr, player);

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
    _DeathEvent(dxr, victim, Killer, damageType, HitLocation, "PawnDeath");
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
