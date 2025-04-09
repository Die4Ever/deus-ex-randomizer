class PlaceholderContainer extends #var(prefix)CrateUnbreakableMed;

// just for containers to be swapped into this location, will be deleted in PostAnyEntry of DXRSwapItems

function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();

    if(!class'DXRVersion'.static.VersionIsStable()) {
        Mesh=LodMesh'DeusExItems.TestBox';
    }
}

simulated function PreBeginPlay()
{
    Super.PreBeginPlay();

#ifdef locdebug
    if("#var(locdebug)"~="PlaceholderContainer") DXRActorsBase(class'DXRActorsBase'.static.Find()).DebugMarkKeyPosition(Location, Name);
#endif
}

defaultproperties
{
    ItemName="Randomizer Placeholder: REPORT BUG!"
    Mesh=None
}
