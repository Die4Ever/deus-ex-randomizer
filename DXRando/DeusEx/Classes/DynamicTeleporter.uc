class DynamicTeleporter extends Teleporter;

var name destName;
var int yaw;

function SetDestination(string destURL, name dest_actor_name, optional string tag, optional int dest_yaw)
{// TODO: make dest_yaw a required argument, have to add rotations to DXRBacktracking
    URL = destURL $ "#" $ tag;
    destName = dest_actor_name;
    yaw = dest_yaw;
    log(Self$": SetDestination("$destURL$", "$dest_actor_name$", " $ yaw $", "$tag$") URL: "$URL$", destName: "$destName);
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

static function name GetToName(DeusExPlayer player, out int yaw)
{
    yaw = player.flagbase.GetInt('DynTeleportYaw');
    return player.flagbase.GetName('DynTeleport');
}

static function bool GetToPos(DeusExPlayer player, out vector pos)
{
    if(player.flagbase.CheckFlag('DynTeleportPos', FLAG_Vector)) {
        pos = player.flagbase.GetVector('DynTeleportPos');
        return true;
    }
    return false;
}

static function ClearTeleport(DeusExPlayer player)
{
    player.flagbase.DeleteFlag('DynTeleport', FLAG_Name);
    player.flagbase.DeleteFlag('DynTeleportPos', FLAG_Vector);
    player.flagbase.DeleteFlag('DynTeleportYaw', FLAG_Int);
}

static function SetDestName(DeusExPlayer player, name destName, optional int yaw)
{
    player.flagbase.SetName('DynTeleport', destName,, 999);
    player.flagbase.SetInt('DynTeleportYaw', yaw,, 999);
}

static function SetDestPos(DeusExPlayer player, vector pos, vector coords_mult)
{
    pos.X /= coords_mult.X;
    pos.Y /= coords_mult.Y;
    pos.Z /= coords_mult.Z;
    player.flagbase.SetVector('DynTeleportPos', pos,, 999);
}

simulated function Touch( actor Other )
{
    local DeusExPlayer p;
    if ( !bEnabled )
        return;

    p = DeusExPlayer(Other);
    if( p != None ) {
        SetDestName(p, destName, yaw);
    }

    Super.Touch(Other);
}

static function bool CheckTeleport(DeusExPlayer player, vector coords_mult)
{
    local name toname;
    local Actor a;
    local vector pos;
    local bool got_pos;
    local int yaw;

    toname = GetToName(player, yaw);
    got_pos = GetToPos(player, pos);
    if( toname == '' && !got_pos ) return true;
    ClearTeleport(player);

    if(got_pos) {
        pos *= coords_mult;
        return player.SetLocation(pos);
    }

    foreach player.AllActors(class'Actor', a) {
        if( a.Name == toname ) {
            if(yaw != 0) {
                player.ViewRotation = class'DXRBase'.static.rotm_static(0, yaw, 0, 16384, coords_mult);
            }
            return player.SetLocation(a.Location);
        }
    }

    return false;
}

static function DynamicTeleporter ReplaceTeleporter(Teleporter t)
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
        dt.bHidden = t.bHidden;
        dt.DrawScale = t.DrawScale;
        t.bHidden = true;
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
