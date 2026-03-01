class DXRBigContainers extends #var(prefix)Containers;

struct Content
{
    var class<Actor> type;
    var int numCopies;
};

var travel Content bcContents[32];
var travel int numContents;

var() travel int MaxContentCount; //Total maximum number of items allowed in a crate
var() travel int ContentTypeLimit; //Maximum number for any one type of item
var() travel bool DropStacks; //Should this drop stackable items as stacks?

var() travel float ThrowMult; //How hard items should be thrown when crate is broken (0 means no throw)

function bool AddExistingItem(Actor item)
{
    local int copies;

    if (item==None) return false;

    if (Pickup(item)!=None){
        copies = Pickup(item).NumCopies;
    }
    if (copies<=0){  //Ammo has NumCopies set to 0, for example
        copies = 1;
    }

    if (AddContent(item.Class,copies)){
        log("Added existing item "$item$" to BigContainer "$self);
        item.Destroy();
        return true;
    }
    return false;

}

function bool AddContent(class<Actor> type, int numCopies)
{
    local int i;

    if (type == None) {
        log("Tried to add None to " $ self);
        return false;
    }

    //Check if item type already in crate
    i = ContentTypeInside(type);
    if (i != -1){
        if (!CanAddMoreOfContent(type)){
            log(self $ " can't add more content type "$type);
            return false;
        }
        //Add to the existing type
        bcContents[i].numCopies += numCopies;
        log(self $ " added " $ numCopies @ type);
        return true;
    }

    //Need to add new type
    if (ContainerIsFull()) {
        log(self $ " max contents exceeded");
        return false;
    }

    bcContents[numContents].type = type;
    bcContents[numContents].numCopies = numCopies;
    numContents++;

    log(self $ " added " $ numCopies @ type);
    return true;
}

function bool CanAddContent(class<Actor> type)
{
    //Can add to the existing count if the type is already in the crate
    if (ContentTypeInside(type)!=-1){
        return CanAddMoreOfContent(type);
    }

    //Need to add new type to the list
    return !ContainerIsFull();
}

function bool CanAddMoreOfContent(class<Actor> type)
{
    local int i;

    if (ContainerIsFull()) return False;

    i = ContentTypeInside(type);
    if (i!=-1){
        return bcContents[i].numCopies <= ContentTypeLimit;
    }

    return true;
}

function int ContentTypeInside(class<Actor> type)
{
    local int i;

    //Check if item type already in crate
    for (i=0;i<numContents;i++){
        if (bcContents[i].type==type){
            //Item type is already in crate, can add to that
            return i;
        }
    }

    return -1;
}

function bool ContainerIsFull()
{
    if (GetTotalContentCount() >= MaxContentCount) return true;

    return (numContents == ArrayCount(bcContents));
}

function int GetContentQuantity(class<Actor> type)
{
    local int i;

    i = ContentTypeInside(type);

    if (i == -1) return 0;

    return bcContents[i].numCopies;
}

function int GetTotalContentCount()
{
    local int i,total;

    for (i=0;i<numContents;i++){
        if (bcContents[i].type!=None){
            if (bcContents[i].type == class'#var(prefix)Credits') {
                //numCopies for credits is just how much money, it all gets compressed into one item
                total += 1;
            } else {
                total += bcContents[i].numCopies;
            }
        }
    }

    return total;
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
    if (ThrowMult > 0){
        dropped.Velocity = vector(rt) * 300 + vect(0,0,220) + dropped.Velocity;
        dropped.Velocity *= ThrowMult;
    }
    dropped.GotoState('Pickup', 'Dropped');
    log(self$" dropped "$dropped);
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

        if (bcContents[i].type == class'#var(prefix)Credits') {
            dropped = Spawn(class'#var(prefix)Credits');
            Credits(dropped).numCredits = bcContents[i].numcopies;
            DropItem(dropped);
        } else if (
            ClassIsChildOf(bcContents[i].type, class'DeusExPickup')
            && class<DeusExPickup>(bcContents[i].type).default.bCanHaveMultipleCopies
            && DropStacks
        ) {
            // TODO: take into account type's reduced maxCopies
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

defaultproperties
{
    MaxContentCount=9999
    ContentTypeLimit=9999
    DropStacks=true
    ThrowMult=0.0
}
