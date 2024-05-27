class DXRWaltonSimons injects WaltonSimons;

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
