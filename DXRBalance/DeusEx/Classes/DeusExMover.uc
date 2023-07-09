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
        BasePos = Location;
    }
}

function float CalcDamage(int iDamage, name damageType)
{
    local float Damage;
    if (iDamage < minDamageThreshold) return 0;
    Damage = float(iDamage);

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
    /*if( EncroachDamage < 1 && Pawn(Other) == None ) {
        Other.TakeDamage( 1000, Instigator, Other.Location, vect(0,0,0), 'Crushed' );
        Other.TakeDamage( 1000, Instigator, Other.Location, vect(0,0,0), 'Exploded' );
    }*/
    return Super.EncroachingOn(Other);
}

/*
function Frob(Actor Frobber, Inventory frobWith)
{
    local bool show_keys;

    show_keys = bool(DeusExPlayer(Frobber).ConsoleCommand("get DeusEx.MenuChoice_ShowKeys enabled"));

    //If trying to lockpick a door that you have the key for...
	if (show_keys && !bDone && frobWith != None && KeyIDNeeded != '')
	{
	    // check for the use of lockpicks
        if (bPickable && frobWith.IsA('Lockpick') && bLocked)
        {
            if (DeusExPlayer(Frobber).KeyRing.HasKey(KeyIDNeeded)){
                //Could automatically use the keyring?
                return _Frob(Frobber,DeusExPlayer(Frobber).KeyRing);

                //Could just reject you with a message saying you have the key
            }
        }
    }
    return _Frob(Frobber,frobWith);
}
*/
