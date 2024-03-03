class PlaceholderItem extends #var(prefix)Flare;

// just for items to be swapped into this location, will be deleted in PostAnyEntry of DXRSwapItems

function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();

    if(!class'DXRVersion'.static.VersionIsStable()) {
        Mesh=LodMesh'DeusExItems.TestBox';
        PickupViewMesh=LodMesh'DeusExItems.TestBox';
    }
}

defaultproperties
{
    ItemName="Randomizer Placeholder: REPORT BUG!"
    Mesh=None
    PickupViewMesh=None
    CollisionRadius=9.300000// copied from AmmoShell
    CollisionHeight=10.210000
}
