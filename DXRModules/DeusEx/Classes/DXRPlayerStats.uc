class DXRPlayerStats extends DXRBase transient;

function PlayerAnyEntry(#var(PlayerPawn) p)
{
    local int i;
    i = dxr.flags.settings.health;
    i = Max(1, i);// need at least 1 health
    p.default.HealthHead = i;
    p.default.HealthTorso = i;
    p.default.HealthLegLeft = i;
    p.default.HealthLegRight = i;
    p.default.HealthArmLeft = i;
    p.default.HealthArmRight = i;

    CapHealth(p.HealthHead, p.default.HealthHead);
    CapHealth(p.HealthTorso, p.default.HealthTorso);
    CapHealth(p.HealthLegLeft, p.default.HealthLegLeft);
    CapHealth(p.HealthLegRight, p.default.HealthLegRight);
    CapHealth(p.HealthArmLeft, p.default.HealthArmLeft);
    CapHealth(p.HealthArmRight, p.default.HealthArmRight);

    i = dxr.flags.settings.energy;
    i = Max(0, i);// need at least 0 for max energy
    p.default.EnergyMax = i;
    p.EnergyMax = i;
    p.default.Energy = Min(p.default.Energy, p.default.EnergyMax);
    p.Energy = Min(p.Energy, p.default.EnergyMax);
}

function CapHealth(out int health, int d)
{
    health = Min(health, d);
}
