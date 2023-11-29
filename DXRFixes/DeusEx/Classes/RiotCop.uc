class DXRRiotCopy injects RiotCop;

function GotoDisabledState(name damageType, EHitLocation hitPos)
{
    Super(HumanMilitary).GotoDisabledState(damageType, hitPos);
}
