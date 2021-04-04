class DynamicTeleporter extends Teleporter;

var float proxCheckTime;
var float Radius;
var name destName;

function SetDestination(string destURL, name dest_actor_name)
{
    URL = destURL $ "#";
    destName = dest_actor_name;
}

simulated function Tick(float deltaTime)
{
    local DeusExPlayer Player;
    Super.Tick(deltaTime);
    proxCheckTime += deltaTime;
    if (proxCheckTime > 0.1)//every 100ms
    {
        proxCheckTime = 0;
        foreach RadiusActors(class'DeusExPlayer', Player, Radius)
        {
            Touch(Player);
        }
    }
}

function Trigger(Actor Other, Pawn Instigator)
{
	Touch(Instigator);
}

static function name GetToName(DeusExPlayer player)
{
    return player.flagbase.GetName('DynTeleport');
}

static function ClearTeleport(DeusExPlayer player)
{
    player.flagbase.SetName('DynTeleport', '',, -999);
}

simulated function Touch( actor Other )
{
    local DeusExPlayer p;
    if ( !bEnabled )
        return;

    p = DeusExPlayer(Other);
    if( p != None ) {
        p.flagbase.SetName('DynTeleport', destName,, 999);
    }

    Super.Touch(Other);
}

static function CheckTeleport(DeusExPlayer player)
{
    local name toname;
    local Actor a;

    toname = GetToName(player);
    if( toname == '' ) return;

    foreach player.AllActors(class'Actor', a) {
        if( a.Name == toname ) {
            player.SetLocation(a.Location);
            break;
        }
    }
    ClearTeleport(player);
}

defaultproperties
{
    bGameRelevant=True
    bCollideActors=False
    bStatic=False
    Radius=160
}
