class DXRInfiniteCrate extends Containers;

var travel string icContents;

function bool AddContent(class<Actor> type, int numCopies)
{
    if (type == None) { // needed?
        log("Tried to add class'None' to DXRInfiniteCrate");
        return false;
    }

    icContents = icContents $ type $ "," $ numCopies $ ";";
    log("DXRInfiniteCrate added " $ numCopies @ type);
    return true;
}

function DropItem(Actor dropped)
{
	local Vector loc;
	local Rotator rt;

    loc = Location + VRand()*CollisionRadius;
    loc.Z = Location.Z;
    rt = rot(0, 0, 0);
    rt.Yaw = Rand(65535);

    dropped.RemoteRole = ROLE_DumbProxy;
    dropped.SetPhysics(PHYS_Falling);
    dropped.bCollideWorld = true;
    dropped.Velocity = VRand() * 50;
    dropped.GotoState('Pickup', 'Dropped');
    dropped.SetLocation(loc);
    dropped.SetRotation(rt);
}

function Destroyed()
{
    local class<Actor> type;
    local int numCopies, maxCopies;
    local string typeStr, numCopiesStr;
    local DXRando dxr;
    local class<DeusExPickup> pickupType;
    local Pickup pu;
    local Actor dropped;

    while (icContents != "") {
        typeStr = Left(icContents, InStr(icContents, ","));
        type = class<Actor>(DynamicLoadObject(typeStr, class'Class'));
        icContents = Right(icContents, Len(icContents) - Len(typeStr) - 1);

        numCopiesStr = Left(icContents, InStr(icContents, ";"));
        numCopies = Int(numCopiesStr);
        icContents = Right(icContents, Len(icContents) - Len(numCopiesStr) - 1);

        log("DXRInfiniteCrate dropping " $ numCopies @ type);

        if (type == class'Credits') {
            dropped = Spawn(class'Credits');
            Credits(dropped).numCredits = numCopies;
            DropItem(dropped);
        } else if (ClassIsChildOf(type, class'DeusExPickup') && class<DeusExPickup>(type).default.bCanHaveMultipleCopies) {
            pickupType = class<DeusExPickup>(type);
            dxr = class'DXRando'.default.dxr;

            if (pickupType == class'Medkit') {
                maxCopies = dxr.flags.settings.medkits;
            } else if (pickupType == class'Multitool') {
                maxCopies = dxr.flags.settings.multitools;
            } else if (pickupType == class'Lockpick') {
                maxCopies = dxr.flags.settings.lockpicks;
            } else if (pickupType == class'BioelectricCell') {
                maxCopies = dxr.flags.settings.biocells;
            } else {
                maxCopies = pickupType.default.maxCopies;
            }

            while (numCopies > pickupType.default.maxCopies) {
                pu = Spawn(pickupType);
                pu.numCopies = pickupType.default.maxCopies;
                DropItem(pu);
                numCopies -= pickupType.default.maxCopies;
            }
            pu = Spawn(pickupType);
            pu.numCopies = numCopies;
            DropItem(pu);
        } else {
            while (numCopies > 0) {
                DropItem(Spawn(type));
                numCopies--;
            }
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
