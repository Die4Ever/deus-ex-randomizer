class DeusExMover merges DeusExMover;
// need to figure out states compatibility https://github.com/Die4Ever/deus-ex-randomizer/issues/135
function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
    if (bDestroyed)
        return;

    if ((damageType == 'TearGas') || (damageType == 'PoisonGas') || (damageType == 'HalonGas'))
        return;

    if ((damageType == 'Stunned') || (damageType == 'Radiation'))
        return;

    if ((DamageType == 'EMP') || (DamageType == 'NanoVirus') || (DamageType == 'Shocked'))
        return;

    if (bBreakable)
    {
        // add up the damage
        if (Damage >= minDamageThreshold)
            doorStrength -= CalcDamage(Damage, damageType);
//      else
//          doorStrength -= Damage * 0.001;		// damage below the threshold does 1/10th the damage

        doorStrength = FClamp(doorStrength, 0.0, 1.0);
        if (doorStrength ~= 0.0)
            BlowItUp(instigatedBy);
    }
}

function float CalcDamage(float Damage, name damageType)
{
    if (Damage < minDamageThreshold) return 0;

    if ((damageType == 'TearGas') || (damageType == 'PoisonGas') || (damageType == 'HalonGas'))
        return 0;

    if ((damageType == 'Stunned') || (damageType == 'Radiation'))
        return 0;

    if ((DamageType == 'EMP') || (DamageType == 'NanoVirus') || (DamageType == 'Shocked'))
        return 0;

    switch(ExplodeSound1) {
        case Sound'DeusExSounds.Generic.GlassBreakLarge':
            return Damage * 0.01;
        case Sound'DeusExSounds.Generic.GlassBreakSmall':
            return Damage * 0.01;
        case Sound'DeusExSounds.Generic.WoodBreakSmall':
            return Damage * 0.005;
        case Sound'DeusExSounds.Generic.SmallExplosion1':
            return Damage * 0.002;
        default:
            //log("WARNING: "$self$": CalcDamage unknown ExplodeSound1: "$ExplodeSound1);
            return Damage * 0.002;
    }
    return Damage * 0.002;
}

function bool EncroachingOn( actor Other )
{
    if( Inventory(Other) != None ) {
        return false;
    }
    if( EncroachDamage < 1 && Pawn(Other) == None ) {
        Other.TakeDamage( 1000, Instigator, Other.Location, vect(0,0,0), 'Crushed' );
        Other.TakeDamage( 1000, Instigator, Other.Location, vect(0,0,0), 'Exploded' );
    }
    return Super.EncroachingOn(Other);
}
