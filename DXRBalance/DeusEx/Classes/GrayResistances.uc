class Gray injects Gray;

function bool FilterDamageType(Pawn instigatedBy, Vector hitLocation,
                               Vector offset, Name damageType)
{
    // Grays aren't affected by radiation or fire or gas, except in DXRando!
    if ((damageType == 'Radiation') /*|| (damageType == 'Flamed') || (damageType == 'Burned')*/)
        return false;
    else if ((damageType == 'TearGas') || (damageType == 'HalonGas') || (damageType == 'PoisonGas'))
        return false;
    else
        return Super(Animal).FilterDamageType(instigatedBy, hitLocation, offset, damageType);
}

function float ModifyDamage(int Damage, Pawn instigatedBy, Vector hitLocation,
                            Vector offset, Name damageType)
{
    local float actualDamage;

    actualDamage = Super.ModifyDamage(Damage, instigatedBy, hitLocation, offset, damageType);

    if (damageType == 'Flamed' || damageType == 'Burned')
        actualDamage *= 0.1;

    return actualDamage;
}

defaultproperties
{
    BurnPeriod=0.0
}
