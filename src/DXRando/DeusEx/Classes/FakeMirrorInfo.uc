class FakeMirrorInfo extends DebugBox;

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

    fmi.item = "FakeMirrorInfo";
    fmi.Group = 'FakeMirrorInfo';

    return fmi;
}
