class FakeMirrorInfo extends Info;

var vector min_pos;
var vector max_pos;

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

function bool IsPointInMyMirrorZone(vector point)
{
    if (point.X > max_pos.X) return false;
    if (point.Y > max_pos.Y) return false;
    if (point.Z > max_pos.Z) return false;

    if (point.X < min_pos.X) return false;
    if (point.Y < min_pos.Y) return false;
    if (point.Z < min_pos.Z) return false;

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

static function FakeMirrorInfo Create(Actor a, vector new_min_pos, vector new_max_pos)
{
    local FakeMirrorInfo fmi;

    fmi = a.Spawn(class'FakeMirrorInfo');
    fmi.SetZone(new_min_pos,new_max_pos);

    return fmi;
}
