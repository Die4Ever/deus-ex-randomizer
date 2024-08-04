class WeaponMrXPunch extends WeaponZombieSwipe;

simulated function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
    // the X vector is used for momentum, send them flying!
    Super.ProcessTraceHit(Other, HitLocation, HitNormal, X*10, Y, Z);
}

defaultproperties
{
    maxRange=130
    AccurateRange=130
    ShotTime=0.4
    HitDamage=20
}
