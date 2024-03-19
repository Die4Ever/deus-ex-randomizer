class PlaceholderContainer extends #var(prefix)CrateUnbreakableMed;

// just for containers to be swapped into this location, will be deleted in PostAnyEntry of DXRSwapItems

function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();

    if(!class'DXRVersion'.static.VersionIsStable()) {
        Mesh=LodMesh'DeusExItems.TestBox';
    }
}

defaultproperties
{
    ItemName="Randomizer Placeholder: REPORT BUG!"
    Mesh=None
}
