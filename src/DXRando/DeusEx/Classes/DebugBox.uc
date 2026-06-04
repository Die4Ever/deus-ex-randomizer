class DebugBox extends Info;

var vector min_pos;
var vector max_pos;

var color boxColour;

var Actor attach;
var vector attachStartLoc;
var bool wasAttached; //So we can differentiate between never being attached and the attached thing getting destroyed

var string item;
var string desc;

function SetZone(vector new_min_pos, vector new_max_pos)
{
    local vector middle;

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

    middle.X = (min_pos.X + max_pos.X)/2;
    middle.Y = (min_pos.Y + max_pos.Y)/2;
    middle.Z = (min_pos.Z + max_pos.Z)/2;
    SetLocation(middle);
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

function SetBoxColour(int r, int g, int b)
{
    boxColour.R = r;
    boxColour.G = g;
    boxColour.B = b;
}

static function DebugBox CreateDB(Actor a, vector new_min_pos, vector new_max_pos, optional Actor attached, optional name grp, optional string itm, optional string descript)
{
    local DebugBox db;

    //Early return if not #bool(debug)?  So these could be placed more freely in fixups code and stuff too?

    db = a.Spawn(class'DebugBox');
    db.SetZone(new_min_pos,new_max_pos);
    db.SetAttached(attached);

    db.item = itm;  //Intended to be the specific item this DebugBox is related to
    db.desc = descript; //Any additional details you might want to provide
    db.Group=grp; //A more broad grouping (eg. the module making the box, etc)

    return db;
}

defaultproperties
{
    boxColour=(R=255,G=255,B=255,A=0)
}
