class DXRInfiniteCrate extends Containers;

var travel DXRInfiniteCrateContent icContents;

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

function DropItem(Actor dropped)
{
    dropped.RemoteRole = ROLE_DumbProxy;
    dropped.SetPhysics(PHYS_Falling);
    dropped.bCollideWorld = true;
    dropped.Velocity = VRand() * 50;
    dropped.GotoState('Pickup', 'Dropped');
}

function Destroyed()
{
    local DXRInfiniteCrateContent icc, iccPrev;
	local Rotator rt;
	local Vector loc;
    local Actor dropped;
    local Pickup pu;
    local class<DeusExPickup> pickupType;
    local int i;

    icc = icContents;
    while (icc != None) {
        loc = Location + VRand()*CollisionRadius;
        loc.Z = Location.Z;
        rt = rot(0,0,0);
        rt.Yaw = Rand(65535);

        if (icc.type == class'Credits') {
            dropped = Spawn(class'Credits',,, loc, rt);
            Credits(dropped).numCredits = icc.NumCopies;
            DropItem(dropped);
        } else if (ClassIsChildOf(icc.class, class'DeusExPickup') && class<DeusExPickup>(icc.type).default.bCanHaveMultipleCopies) {
            pickupType = class<DeusExPickup>(icc.type);
            while (icc.numCopies > pickupType.default.maxCopies) {
                pu = Spawn(pickupType,,, loc, rt);
                pu.numCopies = pickupType.default.maxCopies;
                DropItem(pu);
                icc.numCopies -= pickupType.default.maxCopies;
            }
            pu = Spawn(pickupType,,, loc, rt);
            pu.numCopies = icc.numCopies;
            DropItem(pu);
        } else {
            for (i = 0; i < icc.numCopies; i++) {
                DropItem(Spawn(icc.type,,, loc, rt));
            }
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
