class DXRGuntherHermann injects GuntherHermann;

// if his shields are down, allow him to be stunned/gassed
function GotoDisabledState(name damageType, EHitLocation hitPos)
{
    if(ShieldDamage(damageType) < 1) {
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
