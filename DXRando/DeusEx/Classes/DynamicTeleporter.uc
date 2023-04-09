class DynamicTeleporter extends #var(prefix)Teleporter;

var name destName;

function SetDestination(string destURL, name dest_actor_name, optional string tag)
{
    URL = destURL $ "#" $ tag;
    destName = dest_actor_name;
    log(Self$": SetDestination("$destURL$", "$dest_actor_name$", "$tag$") URL: "$URL$", destName: "$destName);
}

event PostPostBeginPlay()
{// PostPostBeginPlay is also called when loading saved games, so we need this for backwards compatibility
    Super.PostPostBeginPlay();
    SetCollision(true,false,false);
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
        dt.SetCollisionSize(t.CollisionRadius,t.CollisionHeight);
    }
    log("ReplaceTeleporter("$t$") "$dt);
    return dt;
}

defaultproperties
{
    bHidden=False
    bGameRelevant=True
    bCollideActors=True
    bStatic=False
}
