class WeaponMrXPunch extends WeaponZombieSwipe;

simulated function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
    // the X vector is used for momentum, send them flying!
    Super.ProcessTraceHit(Other, HitLocation, HitNormal, X*10, Y, Z);
}

simulated function PlayFakeHitSound()
{
    const HitPitch=0.75;

    //Play the hit sound (directly, so we can adjust pitch)
    if ( Level.NetMode == NM_Standalone )
        Owner.PlaySound(Sound'DeusExSounds.Weapons.CrowbarHitFlesh', SLOT_None,,, 1024, HitPitch);
    else
        Owner.PlayOwnedSound(Sound'DeusExSounds.Weapons.CrowbarHitFlesh', SLOT_None,,, 1024, HitPitch);
}

function SpawnEffects(Vector HitLocation, Vector HitNormal, Actor Other, float Damage)
{
    Super.SpawnEffects(HitLocation,HitNormal,Other,Damage);
    PlayFakeHitSound();
}

simulated function SpawnEffectSounds( Vector HitLocation, Vector HitNormal, Actor Other, float Damage )
{
    Super.SpawnEffectSounds(HitLocation,HitNormal,Other,Damage);
    PlayFakeHitSound();
}

defaultproperties
{
    Misc1Sound=None
    Misc2Sound=None
    Misc3Sound=None
    maxRange=130
    AccurateRange=130
    ShotTime=0.4
    HitDamage=20
}
