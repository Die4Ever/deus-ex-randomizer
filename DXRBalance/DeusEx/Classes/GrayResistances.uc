class Gray injects Gray;
// take a little bit of damage from fire and plasma, also slightly worse than perfect accuracy
function bool FilterDamageType(Pawn instigatedBy, Vector hitLocation,
                               Vector offset, Name damageType)
{
    if(class'MenuChoice_BalanceEtc'.static.IsDisabled())
        return Super.FilterDamageType(instigatedBy, hitLocation, offset, damageType);

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

function BeginPlay()
{
    if(class'MenuChoice_BalanceEtc'.static.IsEnabled()) {
        BaseAccuracy=0.1;
    } else {
        BaseAccuracy=0;
    }
    default.BaseAccuracy=BaseAccuracy;
    Super.BeginPlay();
}

defaultproperties
{
    BurnPeriod=0.0
    BaseAccuracy=0.1
}
