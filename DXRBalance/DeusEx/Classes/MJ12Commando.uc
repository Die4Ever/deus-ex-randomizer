class DXRMJ12Commando injects MJ12Commando;

function float ModifyDamage(int Damage, Pawn instigatedBy, Vector hitLocation,
                            Vector offset, Name damageType)
{
    if(damageType == 'Sabot') Damage *= 2;
    return Super.ModifyDamage(Damage, instigatedBy, hitLocation, offset, damageType);
}

function PlayPanicRunning()
{
    PlayRunning();
}

// if his shields are down, allow him to be stunned/gassed
function GotoDisabledState(name damageType, EHitLocation hitPos)
{
    if(EmpHealth > 0) {
        MaybeDrawShield();
        Super.GotoDisabledState(damageType, hitPos);
    }
    else
        Super(HumanMilitary).GotoDisabledState(damageType, hitPos);
}

defaultproperties
{
    BurnPeriod=5.0
}
