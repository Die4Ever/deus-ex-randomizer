class DXRInfiniteCrate extends Containers;

var DXRInfiniteCrateContent icContents;

function bool AddContent(class<Actor> type, int numCopies)
{
    local DXRInfiniteCrateContent icc;

    icc = Spawn(class'DXRInfiniteCrateContent');
    icc.type = type;
    icc.numCopies = numCopies;

    icc.next = icContents;
    icContents = icc;

    log("DXRInfiniteCrate added " $ numCopies @ type);

    return true;
}

function Destroyed()
{
    local DXRInfiniteCrateContent icc, iccPrev;
	local Rotator rot;
	local Vector loc;
    local Actor dropped;
    local string hint, details;
    local SkillAwardTrigger st;

    icc = icContents;
    while (icc != None) {
        loc = Location + VRand()*CollisionRadius;
        loc.Z = Location.Z;
        rot = rot(0,0,0);
        rot.Yaw = Rand(65535);

        dropped = Spawn(icc.type,,, loc, rot);
        if (dropped != None) {
            if (Credits(dropped) != None) {
                Credits(dropped).numCredits = icc.NumCopies;
            } else if (Pickup(dropped) != None) {
                Pickup(dropped).NumCopies = icc.NumCopies;
            }

            dropped.RemoteRole = ROLE_DumbProxy;
            dropped.SetPhysics(PHYS_Falling);
            dropped.bCollideWorld = true;
            dropped.Velocity = VRand() * 50;
            dropped.GotoState('Pickup', 'Dropped');
        }

        iccPrev = icc;
        icc = icc.next;
        iccPrev.Destroy();
    }

    Super(DeusExDecoration).Destroyed();
}

defaultproperties
{
     HitPoints=1
     FragType=Class'DeusEx.WoodFragment'
     ItemName="Crate"
     bBlockSight=True
     Skin=Texture'BlankWoodenCrate'
     Mesh=LodMesh'DeusExDeco.CrateBreakableMed'
     CollisionRadius=34.000000
     CollisionHeight=24.000000
     Mass=50.000000
     Buoyancy=60.000000
}
