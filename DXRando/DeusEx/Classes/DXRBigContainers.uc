class DXRBigContainers extends #var(prefix)Containers;

struct Content
{
    var class<Actor> type;
    var int numCopies;
};

var travel Content bcContents[30];
var travel int numContents;

function bool AddContent(class<Actor> type, int numCopies)
{
    if (type == None) {
        log("Tried to add None to " $ self);
        return false;
    }
    if (numContents == ArrayCount(bcContents)) {
        log(self $ " max contents exceeded");
        return false;
    }

    bcContents[numContents].type = type;
    bcContents[numContents].numCopies = numCopies;
    numContents++;

    log(self $ " added " $ numCopies @ type);
    return true;
}

function DropItem(Actor dropped)
{
	local Vector loc;
	local Rotator rt;

    loc = Location + VRand() * CollisionRadius;
    loc.Z = Location.Z;
    rt = rot(0, 0, 0);
    rt.Yaw = Rand(65535);

    dropped.SetLocation(loc);
    dropped.SetRotation(rt);
    dropped.RemoteRole = ROLE_DumbProxy;
    dropped.SetPhysics(PHYS_Falling);
    dropped.bCollideWorld = true;
    dropped.Velocity = VRand() * 50;
    dropped.GotoState('Pickup', 'Dropped');
}

function Destroyed()
{
    local Actor dropped;
    local int i;

    if (HitPoints > 0) {
        Super(#var(DeusExPrefix)Decoration).Destroyed();
        return;
    }

    for (i = 0; i < numContents; i++) {
        log(self $ " dropping " $ bcContents[i].numcopies @ bcContents[i].type);

        if (bcContents[i].type == class'Credits') {
            dropped = Spawn(class'Credits');
            Credits(dropped).numCredits = bcContents[i].numcopies;
            DropItem(dropped);
        } else if (
            ClassIsChildOf(bcContents[i].type, class'DeusExPickup')
            && class<DeusExPickup>(bcContents[i].type).default.bCanHaveMultipleCopies
        ) {
            // TODO: take into account type.maxCopies
            dropped = Spawn(bcContents[i].type);
            DeusExPickup(dropped).numCopies = bcContents[i].numcopies;
            DropItem(dropped);
        } else {
            while (bcContents[i].numcopies > 0) {
                DropItem(Spawn(bcContents[i].type));
                bcContents[i].numcopies--;
            }
        }
    }

    Super(DeusExDecoration).Destroyed();
}
