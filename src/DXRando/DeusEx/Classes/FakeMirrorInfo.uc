class FakeMirrorInfo extends Info;

var vector min_pos;
var vector max_pos;

var Actor attach;
var vector attachStartLoc;
var bool wasAttached; //So we can differentiate between never being attached and the attached thing getting destroyed

function SetZone(vector new_min_pos, vector new_max_pos)
{
    if (new_min_pos.X > new_max_pos.X){
        min_pos.X = new_max_pos.X;
        max_pos.X = new_min_pos.X;
    } else {
        min_pos.X = new_min_pos.X;
        max_pos.X = new_max_pos.X;
    }

    if (new_min_pos.Y > new_max_pos.Y){
        min_pos.Y = new_max_pos.Y;
        max_pos.Y = new_min_pos.Y;
    } else {
        min_pos.Y = new_min_pos.Y;
        max_pos.Y = new_max_pos.Y;
    }

    if (new_min_pos.Z > new_max_pos.Z){
        min_pos.Z = new_max_pos.Z;
        max_pos.Z = new_min_pos.Z;
    } else {
        min_pos.Z = new_min_pos.Z;
        max_pos.Z = new_max_pos.Z;
    }
}

function SetAttached(Actor attached)
{
    if (attached==None) return;
    attach = attached;
    attachStartLoc = attach.Location;
    wasAttached = true;
}

//This only works for things that slide (no rotation)
function vector GetAttachedOffset()
{
    if (attach==None) return vect(0,0,0);

    return attach.Location - attachStartLoc;
}

function bool IsValidMirror()
{
    local #var(DeusExPrefix)Mover dxm;

    if (!wasAttached) return True; //If it isn't attached to something, it's always valid

    if (attach==None) return False; //If the attached thing doesn't exist anymore, it isn't valid

    dxm = #var(DeusExPrefix)Mover(attach);
    if (dxm!=None){
        if (dxm.bDestroyed) return False; //If the attached mover was destroyed, it's no longer valid
    }

    return True;
}

function bool IsPointInMyMirrorZone(vector point)
{
    local vector maxLoc,minLoc,attachOffset;

    if (!IsValidMirror()) {
        //No longer valid, guess I'll die
        Destroy();
        return false;
    }

    attachOffset = GetAttachedOffset();

    maxLoc = max_pos + attachOffset;
    minLoc = min_pos + attachOffset;

    if (point.X > maxLoc.X) return false;
    if (point.Y > maxLoc.Y) return false;
    if (point.Z > maxLoc.Z) return false;

    if (point.X < minLoc.X) return false;
    if (point.Y < minLoc.Y) return false;
    if (point.Z < minLoc.Z) return false;

    return true;
}

static function bool IsPointInMirrorZone(Actor a, vector point)
{
    local FakeMirrorInfo fmi;

    foreach a.AllActors(class'FakeMirrorInfo',fmi){
        if (fmi.IsPointInMyMirrorZone(point)) return True;
    }

    return False;
}

static function FakeMirrorInfo Create(Actor a, vector new_min_pos, vector new_max_pos, optional Actor attached)
{
    local FakeMirrorInfo fmi;

    fmi = a.Spawn(class'FakeMirrorInfo');
    fmi.SetZone(new_min_pos,new_max_pos);
    fmi.SetAttached(attached);

    return fmi;
}
