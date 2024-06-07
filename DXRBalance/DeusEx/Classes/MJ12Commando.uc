class DXRMJ12Commando injects MJ12Commando;

function float ModifyDamage(int Damage, Pawn instigatedBy, Vector hitLocation,
                            Vector offset, Name damageType)
{
    if(damageType == 'Sabot') Damage *= 2;
    if(damageType == 'TearGas' || damageType == 'HalonGas') return 0;

    return Super.ModifyDamage(Damage, instigatedBy, hitLocation, offset, damageType);
}

function PlayPanicRunning()
{
    PlayRunning();
}

// if his shields are down, allow him to be stunned
// commandos don't have the rubbing eyes animation
function GotoDisabledState(name damageType, EHitLocation hitPos)
{
    if(damageType != 'TearGas' && damageType != 'HalonGas' && ShieldDamage(damageType) < 1) {
        if(EmpHealth > 0) {
            MaybeDrawShield();
            Super.GotoDisabledState(damageType, hitPos);
        }
        else
            Super(HumanMilitary).GotoDisabledState(damageType, hitPos);
    } else {
        Super.GotoDisabledState(damageType, hitPos);
    }
}

defaultproperties
{
    BurnPeriod=5.0
}
