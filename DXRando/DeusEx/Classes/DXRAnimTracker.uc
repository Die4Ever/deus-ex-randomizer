#ifdef debug
class DXRAnimTracker extends LaserSpot transient config(DXRAnimTracker);
#else
class DXRAnimTracker extends LaserSpot transient;
#endif

// WIP, needs more data, and doesn't handle rotation yet

struct AnimOffsets {
    var name AnimName;
    var float frames[16];
    var vector offsets[16];
    var rotator rotations[16];
};

#ifdef debug
var config vector offset;// default offset when no matched animation
var config float ForceFrame;
var config bool bFPV;

var config AnimOffsets anim_offsets[16];
var config string config_part;
#else
var vector offset;// default offset when no matched animation
var float ForceFrame;
var bool bFPV;

var AnimOffsets anim_offsets[16];
var string config_part;
#endif

static function DXRAnimTracker Create(Pawn owner, string part)
{
    local DXRAnimTracker tracker;
    tracker = owner.spawn(class'DXRAnimTracker', owner);
    tracker.Init(part);
    return tracker;
}

function Init(string part)
{
    local rotator rot;
    local int a, i;

    if(#defined(debug)) SaveConfig();// create/update the config file
    if(#defined(debug) && part == config_part) return;

    for(a=0; a<ArrayCount(anim_offsets); a++) {
        anim_offsets[a].frames[0] = 0;
        anim_offsets[a].frames[1] = 999;
    }
    a=0;

    switch(part) {
    case "first person baton":
        bFPV = true;
        offset = vect(8, 3, 3);// + (Pawn(Owner).BaseEyeHeight * vect(0,0,1));
        /*anim_offsets[a].AnimName = 'Attack';
        anim_offsets[a].offsets[i] = offset;
        anim_offsets[a].frames[i] = -1;
        i++;
        anim_offsets[a].offsets[i] = offset;
        anim_offsets[a].frames[i] = 1;
        i++;*/
        break;

    case "right hand":
        offset = vect(3, 12, -4);

        /*anim_offsets[a].AnimName = 'BreatheLight';
        anim_offsets[a].offsets[0] = offset;
        anim_offsets[a].offsets[1] = offset;
        anim_offsets[a].frames[1] = 1;
        a++;
        i=0;*/

        /*anim_offsets[a].AnimName = 'Run';
        anim_offsets[a].offsets[0] = offset;
        anim_offsets[a].offsets[1] = offset;
        anim_offsets[a].frames[1] = 1;
        a++;
        i=0;*/

        anim_offsets[a].AnimName = 'Attack';
        anim_offsets[a].offsets[i] = offset;
        anim_offsets[a].frames[i] = -1;
        i++;
        anim_offsets[a].offsets[i] = offset;
        anim_offsets[a].frames[i] = -0.14;
        i++;
        anim_offsets[a].offsets[i] = vect(-28, 24, 32);
        anim_offsets[a].frames[i] = 0;
        i++;
        anim_offsets[a].offsets[i] = vect(4, 18, 36);
        anim_offsets[a].frames[i] = 0.1;
        i++;
        anim_offsets[a].offsets[i] = vect(14, 16, 40);
        anim_offsets[a].frames[i] = 0.145;
        i++;
        anim_offsets[a].offsets[i] = vect(28, 0, 16);
        anim_offsets[a].frames[i] = 0.225;
        i++;
        anim_offsets[a].offsets[i] = vect(6, -8, 2);
        anim_offsets[a].frames[i] = 0.49;
        i++;
        anim_offsets[a].offsets[i] = vect(6, -8, 2);
        anim_offsets[a].frames[i] = 0.57;
        i++;
        anim_offsets[a].offsets[i] = vect(5, 16, -2);
        anim_offsets[a].frames[i] = 0.85;
        i++;
        anim_offsets[a].offsets[i] = offset;
        anim_offsets[a].frames[i] = 1;
        a++;
        i=0;
        break;

    case "hat":
        offset = vect(4, 0, 48);
        break;
    }

    if(#defined(debug)) SaveConfig();// write back new values to config
}

simulated function Tick(float deltaTime)
{
    local vector loc, a_off, b_off;
    local int a, i;
    local float a_frame, b_frame, f;

    if(Owner == None) {
        Destroy();
        return;
    }

    if(ForceFrame != -1) Owner.AnimFrame = ForceFrame;
    loc = offset;

    // TODO: handle rotation, probably needs a better default mesh to show it
    for(a=0; a<ArrayCount(anim_offsets); a++) {
        if(anim_offsets[a].AnimName == '') break;
        if(anim_offsets[a].AnimName != Owner.AnimSequence) continue;

        for(i=0; i<ArrayCount(anim_offsets[a].frames); i++) {
            if(Owner.AnimFrame < anim_offsets[a].frames[i]) break;
            a_off = anim_offsets[a].offsets[i];
            a_frame = anim_offsets[a].frames[i];
            loc = a_off;
        }
        if(i<ArrayCount(anim_offsets[a].frames) && anim_offsets[a].frames[i] > Owner.AnimFrame) {
            b_off = anim_offsets[a].offsets[i];
            b_frame = anim_offsets[a].frames[i];

            f = (Owner.AnimFrame - a_frame) / (b_frame - a_frame);
            loc = (a_off * (1.0-f)) + (b_off * f);
        }

        if(#defined(debug)) {
            Human(GetPlayerPawn()).ClientMessage(Owner.AnimSequence @ Owner.AnimFrame @ loc);
        }
        ApplyOffset(loc);
        return;
    }

    if(#defined(debug) && Owner.AnimSequence != '') {
        Human(GetPlayerPawn()).ClientMessage(Owner.AnimSequence @ Owner.AnimFrame);
    }

    ApplyOffset(loc);
}

function ApplyOffset(vector off)
{
    local Pawn p;
    local rotator rot;
    local vector DrawOffset, WeaponBob, x, y, z;
    local float BobDamping;

    p = Pawn(Owner);

    if(bFPV) {
        GetAxes(p.ViewRotation, X,Y,Z);

        DrawOffset = ((0.9/p.Default.FOVAngle * off) >> p.ViewRotation);
        DrawOffset += (p.EyeHeight * vect(0,0,1));
        BobDamping = 0.96;
        if(p.Weapon != None) {
            BobDamping = p.Weapon.BobDamping;
        }
        WeaponBob = BobDamping * p.WalkBob;
        WeaponBob.Z = (0.45 + 0.55 * BobDamping) * p.WalkBob.Z;
        DrawOffset += WeaponBob;
        off = DrawOffset + off.X * X + off.Y * Y + off.Z * Z;
    } else {
        rot.yaw = p.ViewRotation.yaw;
        off = (off * p.DrawScale) >> rot;
    }
    SetLocation(Owner.Location + off);
}

defaultproperties
{
    ForceFrame=-1// set dxranimtracker forceframe 0.5 can be very useful
#ifdef debug
    Mesh=LodMesh'DeusExDeco.Basketball'// about 14 unit radius visually, which can help you judge how much you need to adjust the offsets
#else
    Mesh=None
#endif
    DrawScale=1
}
