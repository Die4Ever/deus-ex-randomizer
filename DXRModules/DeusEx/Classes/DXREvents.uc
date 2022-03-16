class DXREvents extends DXRActorsBase transient;

var #var PlayerPawn  _player;
var bool died;

function PreFirstEntry()
{
    Super.PreFirstEntry();
    switch(dxr.dxInfo.missionNumber) {
        case 99:
            Ending_FirstEntry();
            break;
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

simulated function PlayerRespawn(#var PlayerPawn  player)
{
    Super.PlayerRespawn(player);
    _player = player;
    died = false;
    if( !#defined injections )
        SetTimer(1, true);
}

simulated function PlayerAnyEntry(#var PlayerPawn  player)
{
    Super.PlayerAnyEntry(player);
    _player = player;
    died = false;
    if( !#defined injections )
        SetTimer(1, true);
}

simulated function Timer()
{
    if(_player == None) {
        SetTimer(0, false);
        return;
    }
    if( !#defined injections && _player.IsInState('Dying') && !died) {
        died = true;
        AddDeath(dxr, _player);
    }
}

static function AddDeath(DXRando dxr, #var PlayerPawn  player, optional Actor Killer, optional coerce string damageType, optional vector HitLocation)
{
    local string j;
    local string killername, playername, loadout;
    local Pawn KillerPawn;
    local #var prefix ScriptedPawn sp;
    local #var PlayerPawn  killerplayer;
    local class<Json> js;
    js = class'Json';

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

    killerplayer = #var PlayerPawn (Killer);
    KillerPawn = Pawn(Killer);
    sp = #var prefix ScriptedPawn(Killer);

#ifdef hx
    playername = player.PlayerReplicationInfo.PlayerName;
    if(killerplayer != None) {
        killername = killerplayer.TruePlayerName;
    }
#else
    playername = player.TruePlayerName;
    if(killerplayer != None) {
        killername = killerplayer.TruePlayerName;
    }
#endif
    // bImportant ScriptedPawns don't get their names randomized
    else if(sp != None && sp.bImportant)
        killername = Killer.FamiliarName;
    // randomized names aren't really meaningful here so use their default name
    else if(Killer != None)
        killername = Killer.default.FamiliarName;

    if(damageType == "shot") {
        if( !IsHuman(Killer) && Robot(Killer) == None ) {
            // only humans and robots can shoot? karkians deal shot damage
            damageType = "";
        }
    }

    j = js.static.Start("DEATH");
    js.static.Add(j, "type", "DEATH");
    js.static.Add(j, "player", playername);
    if(Killer != None) {
        js.static.Add(j, "killerclass", Killer.Class.Name);
        js.static.Add(j, "killer", killername);
    }
    js.static.Add(j, "dmgtype", damageType);
    js.static.Add(j, "map", dxr.localURL);
    js.static.Add(j, "mapname", dxr.dxInfo.MissionLocation);
    js.static.Add(j, "mission", dxr.dxInfo.missionNumber);
    js.static.Add(j, "TrueNorth", dxr.dxInfo.TrueNorth);
    js.static.Add(j, "location", player.Location);

    loadout = GetLoadoutName(dxr);
    if(loadout != "")
        js.static.Add(j, "loadout", loadout);
    js.static.End(j);
    class'DXRTelemetry'.static.SendEvent(dxr, player, j);
}

static function PaulDied(DXRando dxr, #var PlayerPawn  player, optional Actor Killer, optional coerce string damageType, optional vector HitLocation)
{
    // we can call this from an injects on PaulDenton, and also on mission 5 first entry
}

static function SavedPaul(DXRando dxr, #var PlayerPawn  player)
{
}

static function BeatGame(DXRando dxr, int ending, int time)
{
    local string j;
    local string playername, loadout;
    local #var PlayerPawn   player;
    local class<Json> js;
    js = class'Json';

    player = dxr.Player;

#ifdef hx
    playername = player.PlayerReplicationInfo.PlayerName;
#else
    playername = player.TruePlayerName;
#endif

    j = js.static.Start("BeatGame");
    js.static.Add(j, "seed", dxr.seed);
    js.static.Add(j, "PlayerName", playername);
    js.static.Add(j, "ending", ending);
    js.static.Add(j, "time", time);
    js.static.Add(j, "SaveCount", player.saveCount);
    loadout = GetLoadoutName(dxr);
    if(loadout != "")
        js.static.Add(j, "loadout", loadout);
    js.static.End(j);

    class'DXRTelemetry'.static.SendEvent(dxr, player, j);
}

static function string GetLoadoutName(DXRando dxr)
{
    local DXRLoadouts loadout;
    loadout = DXRLoadouts(dxr.FindModule(class'DXRLoadouts'));
    if( loadout == None )
        return "";
    return loadout.GetName(loadout.loadout);
}
