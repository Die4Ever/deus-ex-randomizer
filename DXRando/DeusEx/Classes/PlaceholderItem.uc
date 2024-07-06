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

simulated function PreBeginPlay()
{
    local Vector HitLocation, HitNormal,botLoc;
    local Actor HitActor;
    local #var(PlayerPawn) player;

    Super.PreBeginPlay();

    if(!class'DXRVersion'.static.VersionIsStable()) {
        //Make sure placeholders are high enough off the ground so that any swaps can
        //adjust height based on collision size and still stay out of the ground.
        botLoc=Location;
        botLoc.Z=botLoc.Z - CollisionHeight/2;
        HitActor=Trace(HitLocation,HitNormal,botLoc);
        if (HitActor!=None){
            foreach AllActors(class'#var(PlayerPawn)',player){
                player.ClientMessage(self$" is not high enough off the ground!  Distance="$VSize(Location-HitLocation));
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
