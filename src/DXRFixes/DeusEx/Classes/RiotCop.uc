class DXRRiotCop injects #var(prefix)RiotCop;

function GotoDisabledState(name damageType, EHitLocation hitPos)
{
    Super(HumanMilitary).GotoDisabledState(damageType, hitPos);
}
