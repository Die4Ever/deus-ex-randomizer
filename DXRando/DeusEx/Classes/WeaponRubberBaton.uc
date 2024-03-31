class WeaponRubberBaton extends #var(prefix)WeaponBaton;

simulated function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
    HitDamage = default.HitDamage;

    if(Pawn(Other) != None) {
        // we really just want to allow it to damage fish and birds?
        if( !class'DXRActorsBase'.static.IsCritter(Other.class) || #var(prefix)Mutt(Other) != None || #var(prefix)Cat(Other) != None) {
            HitDamage = 0;
        }
    }
    else if(#var(prefix)Carcass(Other) != None) {
        HitDamage = 0;
    }

    Super.ProcessTraceHit(Other, HitLocation, HitNormal, X, Y, Z);

    HitDamage = default.HitDamage;
}

defaultproperties
{
    HitDamage=3
    FireSound=Sound'DeusExSounds.Weapons.BatonFire'
    Misc1Sound=Sound'DeusExSounds.Weapons.BatonHitFlesh'
    Misc2Sound=Sound'DeusExSounds.Weapons.BatonHitHard'
    Misc3Sound=Sound'DeusExSounds.Weapons.BatonHitSoft'
    ItemName="Rubber Baton"
    Description="A rubber baton, could be used to break glass windows or wooden crates. Will not hurt anyone."
    beltDescription="RUBBER"
}
