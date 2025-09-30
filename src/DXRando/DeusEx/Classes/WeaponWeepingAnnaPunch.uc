class WeaponWeepingAnnaPunch extends WeaponZombieSwipe;

simulated function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
    // the X vector is used for momentum, send them flying!
    Super.ProcessTraceHit(Other, HitLocation, HitNormal, X*7, Y, Z);
}

function ReadyToFire()
{
    maxRange = default.maxRange;
    Super.ReadyToFire();
}

function Fire(float Value)
{
    maxRange = default.maxRange*2;
    Super.Fire(Value);
}

simulated function PlayFakeHitSound()
{
    const HitPitch=0.8;

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
    maxRange=110
    AccurateRange=110
    ShotTime=0.2
    HitDamage=15
}
