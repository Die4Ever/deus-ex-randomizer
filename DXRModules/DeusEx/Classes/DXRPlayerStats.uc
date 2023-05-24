class DXRPlayerStats extends DXRBase transient;

function PlayerLogin(#var(PlayerPawn) p)
{
    local int i;
    Super.PlayerLogin(p);

    SetMaxStats(p);

    i = dxr.flags.settings.health;
    i = Max(1, i);// need at least 1 health

    p.HealthHead = i;
    p.HealthTorso = i;
    p.HealthLegLeft = i;
    p.HealthLegRight = i;
    p.HealthArmLeft = i;
    p.HealthArmRight = i;
    p.Health = i;

    i = dxr.flags.settings.energy;
    i = Max(0, i);// need at least 0 for max energy
    p.Energy = i;

    if(dxr.flags.IsZeroRando()) return;

    SetGlobalSeed("DXRPlayerStatsLogin");//independent of map/mission
    p.Energy = rng(p.default.EnergyMax-25)+25;
    p.Energy = Min(p.Energy, p.default.EnergyMax);
    p.Credits = rng(200);
}

function PlayerAnyEntry(#var(PlayerPawn) p)
{
    local bool bFixGlitches;

    SetMaxStats(p);

    if(p.HealthTorso <= 0 || p.HealthHead <= 0) {
        //bFixGlitches = bool(ConsoleCommand("get #var(package).MenuChoice_FixGlitches enabled"));
        // TODO: this one is a bit weird to fix because our code doesn't get run with the glitched load
        if(bFixGlitches) {
            p.TakeDamage(10000, p, p.Location, vect(0,0,0), 'Radiation');
        } else {
            p.ClientMessage("DEAD MAN WALKING GLITCH DETECTED!");
            class'DXRStats'.static.AddCheatOffense(p, 5);// worth more than other glitches
        }
    }
}

function SetMaxStats(#var(PlayerPawn) p)
{
    local int i;
    i = dxr.flags.settings.health;
    i = Max(1, i);// need at least 1 health

#ifdef vmd
    p.ModHealthMultiplier = float(i)/100.0;
    p.default.ModHealthMultiplier = float(i)/100.0;
#else
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
#endif

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
