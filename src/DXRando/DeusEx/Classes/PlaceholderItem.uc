class PlaceholderItem extends #var(prefix)Flare;

// just for items to be swapped into this location, will be deleted in PostFirstEntry of DXRFixup

function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();

    if(!class'DXRVersion'.static.VersionIsStable()) {
        Mesh=LodMesh'DeusExItems.TestBox';
        PickupViewMesh=LodMesh'DeusExItems.TestBox';
    }
}

simulated function PreBeginPlay()
{
    local Vector HitLocation, HitNormal,botLoc;
    local Actor HitActor;
    local #var(PlayerPawn) player;

    Super.PreBeginPlay();

#ifdef locdebug
    if("#var(locdebug)"~="PlaceholderItem") DXRActorsBase(class'DXRActorsBase'.static.Find()).DebugMarkKeyPosition(Location, Name);
#endif

    if(!class'DXRVersion'.static.VersionIsStable()) {
        //Make sure placeholders are high enough off the ground so that any swaps can
        //adjust height based on collision size and still stay out of the ground.
        botLoc=Location;
        botLoc.Z=botLoc.Z - CollisionHeight/2;
        HitActor=Trace(HitLocation,HitNormal,botLoc);
        if (HitActor!=None){
            foreach AllActors(class'#var(PlayerPawn)',player){
                player.ClientMessage(self$" is not high enough off the ground!  Distance="$VSize(Location-HitLocation)$"  Location: "$Location);
            }
        }
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
