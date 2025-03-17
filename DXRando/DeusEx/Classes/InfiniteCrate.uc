class InfiniteCrate extends Containers;

var CrateContent icContents;

function bool AddContent(class<Inventory> type, int numCopies)
{
    local CrateContent cc;

    if (numCopies < 1) {
        return false;
    }

    if (icContents == None) {
        icContents = Spawn(class'CrateContent');
        icContents.type = type;
        icContents.numCopies = numCopies;
    } else {
        for (cc = icContents; cc.next != None; cc = cc.next);
        cc.next = Spawn(class'CrateContent');
        cc.next.type = type;
        cc.next.numCopies = numCopies;
    }

    return true;
}

function Destroyed()
{
    local CrateContent cc;
	local Rotator rot;
	local Vector loc;
    local Inventory dropped;

    for (cc = icContents; cc != None; cc = cc.next) {
        loc = Location + VRand()*CollisionRadius;
        loc.Z = Location.Z;
        rot = rot(0,0,0);
        rot.Yaw = FRand() * 65535;
        dropped = Spawn(cc.type,,, loc, rot);
        if (dropped != None) {
            if (Pickup(dropped) != None) {
                Pickup(dropped).NumCopies = cc.NumCopies;
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
