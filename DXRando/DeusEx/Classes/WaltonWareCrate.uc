class WaltonWareCrate extends Containers;

struct Content
{
    var class<Inventory> type;
    var int numCopies;
};

var Content wwContents[8];
var int numContents;

function bool AddContent(class<Inventory> type, int numCopies)
{
    if (numContents < ArrayCount(wwContents)) {
        wwContents[numContents].type = type;
        wwContents[numContents].numCopies = numCopies;
        numContents++;
        return true;
    }
    return false;
}

function Destroyed()
{
    local int i;
	local Rotator rot;
	local Vector loc;
    local Inventory dropped;

    if ((Pawn(Base) != None) && (Pawn(Base).CarriedDecoration == self)) {
        Pawn(Base).DropDecoration();
    }

    for (i = 0; i < numContents; i++) {
        loc = Location + VRand()*CollisionRadius;
        loc.Z = Location.Z;
        rot = rot(0,0,0);
        rot.Yaw = FRand() * 65535;
        dropped = Spawn(wwContents[i].type,,, loc, rot);
        if (dropped != None) {
            if (Pickup(dropped) != None) {
                Pickup(dropped).NumCopies = wwContents[i].numCopies;
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
     ItemName="WaltonWare Supply Crate"
     contents=Class'VialPoo'
     bBlockSight=True
     Skin=Texture'WaltonWareCrate'
     Mesh=LodMesh'DeusExDeco.CrateBreakableMed'
     CollisionRadius=34.000000
     CollisionHeight=24.000000
     Mass=50.000000
     Buoyancy=60.000000
}
