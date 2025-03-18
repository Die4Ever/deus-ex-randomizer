class InfiniteCrate extends Containers;

var InfiniteCrateContent icContents;

function bool AddContent(class<Inventory> type, int numCopies)
{
    local InfiniteCrateContent icc;

    if (numCopies < 1) {
        return false;
    }

    if (icContents == None) {
        icContents = Spawn(class'InfiniteCrateContent');
        icContents.type = type;
        icContents.numCopies = numCopies;
    } else {
        for (icc = icContents; icc.next != None; icc = icc.next);
        icc.next = Spawn(class'InfiniteCrateContent');
        icc.next.type = type;
        icc.next.numCopies = numCopies;
    }

    return true;
}

function Destroyed()
{
    local InfiniteCrateContent icc;
	local Rotator rot;
	local Vector loc;
    local Inventory dropped;

    for (icc = icContents; icc != None; icc = icc.next) {
        loc = Location + VRand()*CollisionRadius;
        loc.Z = Location.Z;
        rot = rot(0,0,0);
        rot.Yaw = FRand() * 65535;
        dropped = Spawn(icc.type,,, loc, rot);
        if (dropped != None) {
            if (Pickup(dropped) != None) {
                Pickup(dropped).NumCopies = icc.NumCopies;
            }
            dropped.RemoteRole = ROLE_DumbProxy;
            dropped.SetPhysics(PHYS_Falling);
            dropped.bCollideWorld = true;
            dropped.Velocity = VRand() * 50;
            dropped.GotoState('Pickup', 'Dropped');
        }
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
