//=============================================================================
// WineBottle.
//=============================================================================
class WineBottle extends HealingItem;

function Destroyed()
{
    local Vector HitLocation, HitNormal, EndTrace;
    local Actor hit;
    local WinePool pool;

    if (Owner==None){
        // trace down about 20 feet if we're not in water
        if (!Region.Zone.bWaterZone)
        {
            EndTrace = Location - vect(0,0,320);
            hit = Trace(HitLocation, HitNormal, EndTrace, Location, False);
            pool = spawn(class'WinePool',,, HitLocation+HitNormal, Rotator(HitNormal));
            if (pool != None)
                pool.maxDrawScale = CollisionRadius / 5.0;
        }
    }

    Super.Destroyed();
}

defaultproperties
{
    bBreakable=True
    maxCopies=10
    bCanHaveMultipleCopies=True
    bActivatable=True
    ItemName="Wine"
    ItemArticle="some"
    PlayerViewOffset=(X=30.000000,Z=-12.000000)
    PlayerViewMesh=LodMesh'DeusExItems.WineBottle'
    PickupViewMesh=LodMesh'DeusExItems.WineBottle'
    ThirdPersonMesh=LodMesh'DeusExItems.WineBottle'
    LandSound=Sound'DeusExSounds.Generic.GlassHit1'
    Icon=Texture'DeusExUI.Icons.BeltIconWineBottle'
    largeIcon=Texture'DeusExUI.Icons.LargeIconWineBottle'
    largeIconWidth=36
    largeIconHeight=48
    Description="A nice bottle of wine."
    beltDescription="WINE"
    Mesh=LodMesh'DeusExItems.WineBottle'
    CollisionRadius=4.060000
    CollisionHeight=16.180000
    Mass=10.000000
    Buoyancy=8.000000
    health=3
    energy=1
    drugEffect=5.0
}
