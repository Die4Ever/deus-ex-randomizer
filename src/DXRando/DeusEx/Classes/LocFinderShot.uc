//=============================================================================
// LocFinderShot.
//=============================================================================
class LocFinderShot extends DeusExProjectile;

auto simulated state Flying
{
    simulated function HitWall(vector HitNormal, actor Wall)
    {
        local Vector TraceHitLocation, TraceHitNormal, EndTrace, PrevVelocity;
        local Actor hit;
        local DeusExPlayer p;

        PrevVelocity = Velocity;

        Super.HitWall(HitNormal,Wall);

        //Trace it all the way to the actual wall, since it probably actually stopped early
        EndTrace = Location + PrevVelocity;
        hit = Trace(TraceHitLocation,TraceHitNormal,EndTrace,,False);
        SetLocation(TraceHitLocation);
        log("LocFinderShot: "$TraceHitLocation);  //Log the location, in case that's convenient
    }
}

defaultproperties
{
     bStickToWall=True
     DamageType=shot
     spawnAmmoClass=Class'DeusEx.AmmoDart'
     bIgnoresNanoDefense=True
     ItemName="Location Finder Shot"
     ItemArticle="a"
     speed=2000.000000
     MaxSpeed=2000.000000
     Damage=0.000000
     MomentumTransfer=1000
     SpawnSound=Sound'DeusExSounds.Weapons.MiniCrossbowFire'
     ImpactSound=Sound'DeusExSounds.Generic.BulletHitFlesh'
     Mesh=LodMesh'DeusExDeco.Poolball'
     CollisionRadius=1.00000
     CollisionHeight=1.00000
     DrawScale=0.5
     LifeSpan=0.000000
}
