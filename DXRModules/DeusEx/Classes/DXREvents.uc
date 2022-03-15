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
        class'DXRTelemetry'.static.BeatGame(dxr,ending,time);
    }
}

simulated function PlayerRespawn(#var PlayerPawn  player)
{
    Super.PlayerRespawn(player);
    _player = player;
    SetTimer(1, true);
}

simulated function PlayerAnyEntry(#var PlayerPawn  player)
{
    Super.PlayerAnyEntry(player);
    _player = player;
    SetTimer(1, true);
}

simulated function Timer()
{
    if(_player == None) {
        SetTimer(0, false);
        return;
    }
    if(#defined injections == false && _player.IsInState('Dying') && !died) {
        died = true;
        AddDeath(dxr, _player);
    }
}

static function AddDeath(DXRando dxr, #var PlayerPawn  player, optional Actor Killer, optional coerce string damageType, optional vector HitLocation)
{
    class'DXRStats'.static.AddDeath(player);
    class'DXRTelemetry'.static.AddDeath(dxr, player, Killer, damageType, HitLocation);
    class'DXRHints'.static.AddDeath(dxr, player);
}

static function PaulDied(DXRando dxr, #var PlayerPawn  player, optional Actor Killer, optional coerce string damageType, optional vector HitLocation)
{
    // we can call this from an injects on PaulDenton, and also on mission 5 first entry
}

static function SavedPaul(DXRando dxr, #var PlayerPawn  player)
{
}
