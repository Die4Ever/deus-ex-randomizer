class DynamicTeleporter extends #var(prefix)Teleporter;

var float proxCheckTime;
var float Radius;
var name destName;

function SetDestination(string destURL, name dest_actor_name, optional string tag)
{
    URL = destURL $ "#" $ tag;
    destName = dest_actor_name;
    log(Self$": SetDestination("$destURL$", "$dest_actor_name$", "$tag$") URL: "$URL$", destName: "$destName);
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

static function SetDestName(DeusExPlayer player, name destName)
{
    player.flagbase.SetName('DynTeleport', destName,, 999);
}

simulated function Touch( actor Other )
{
    local DeusExPlayer p;
    proxCheckTime = 0;
    if ( !bEnabled )
        return;

    p = DeusExPlayer(Other);
    if( p != None ) {
        SetDestName(p, destName);
    }

    Super.Touch(Other);
}

static function bool CheckTeleport(DeusExPlayer player)
{
    local name toname;
    local Actor a;

    toname = GetToName(player);
    if( toname == '' ) return true;
    ClearTeleport(player);

    foreach player.AllActors(class'Actor', a) {
        if( a.Name == toname ) {
            return player.SetLocation(a.Location);
        }
    }

    return false;
}

static function DynamicTeleporter ReplaceTeleporter(#var(prefix)Teleporter t)
{
    local DynamicTeleporter dt;
    if( DynamicTeleporter(t) != None ) return DynamicTeleporter(t);
    if( ! t.bEnabled ) return None;
    dt = t.Spawn(class'DynamicTeleporter',,,t.Location, t.Rotation);
    if( dt != None ) {
        t.bEnabled = false;
        t.Disable('Touch');
        t.Disable('Trigger');
        t.SetCollision(false, false, false);
        dt.URL = t.URL;
        dt.Radius = t.CollisionRadius;
    }
    log("ReplaceTeleporter("$t$") "$dt);
    return dt;
}

defaultproperties
{
    bGameRelevant=True
    bCollideActors=True
    bStatic=False
    Radius=160
}
