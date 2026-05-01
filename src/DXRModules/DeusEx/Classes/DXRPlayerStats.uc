class DXRPlayerStats extends DXRBase transient;

function PlayerLogin(#var(PlayerPawn) p)
{
    local int i;
    local bool importantHealthNegative;

    Super.PlayerLogin(p);

    SetMaxStats(p);

    importantHealthNegative = (p.HealthHead<=0 || p.HealthTorso<=0);

    if (importantHealthNegative && class'MenuChoice_FixGlitches'.default.enabled){
        //Just die if you don't have health and you want to fix glitches
        //as long as you aren't in an intro or outro
        if (dxr.dxInfo.missionNumber != 98 && //Intro
            dxr.dxInfo.missionNumber != 99){  //Outro
            p.Died(None,'',vect(0,0,0)); //You're dead, buddy
            return;
        }
    }

    //Don't refill health if your health is below 0 and glitches aren't being fixed
    //We still want this to run at the start of the game when glitches aren't being fixed
    //so your health goes up to the max health that was selected
    if(!importantHealthNegative || class'MenuChoice_FixGlitches'.default.enabled) {
        i = dxr.flags.settings.health;
        i = Max(1, i);// need at least 1 health

        p.HealthHead = i;
        p.HealthTorso = i;
        p.HealthLegLeft = i;
        p.HealthLegRight = i;
        p.HealthArmLeft = i;
        p.HealthArmRight = i;
        p.Health = i;
    }

    i = dxr.flags.settings.energy;
    i = Max(0, i);// need at least 0 for max energy
    p.Energy = i;

    if(dxr.flags.IsZeroRando()) return;

    SetGlobalSeed("DXRPlayerStatsLogin");//independent of map/mission
    p.Energy = rng(p.default.EnergyMax-25)+25;
    p.Energy = Min(p.Energy, p.default.EnergyMax);

    if(dxr.flags.IsSpeedrunMode()) {
        p.Energy = p.EnergyMax;
    }

    p.Credits=0;

    class'DXRStartMap'.static.AddStartingCredits(dxr,p);
}

function PlayerAnyEntry(#var(PlayerPawn) p)
{
    local bool bFixGlitches;

    SetMaxStats(p);

    if(p.HealthTorso <= 0 || p.HealthHead <= 0) {
        bFixGlitches = class'MenuChoice_FixGlitches'.default.enabled;
        // TODO: this one is a bit weird to fix because our code doesn't get run with the glitched load
        // It still will with user.ini saves after you're dead and then reload (aka "phoenix")
        if(bFixGlitches) {
            //Just die if you don't have health and you want to fix glitches
            //as long as you aren't in an intro or outro
            if (dxr.dxInfo.missionNumber != 98 && //Intro
                dxr.dxInfo.missionNumber != 99){  //Outro
                p.Died(None,'',vect(0,0,0)); //You're dead, buddy
            }
        } else {
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

    if(OnTitleScreen()) {
        SetHighDefaults(p);
    }
}

function SetHighDefaults(#var(PlayerPawn) p) // to avoid issues with loading saves
{
    local int i;
    if(#bool(vmd)) return; // VMD doesn't use defaults for max

    i = 10000;
    p.default.HealthHead = i;
    p.default.HealthTorso = i;
    p.default.HealthLegLeft = i;
    p.default.HealthLegRight = i;
    p.default.HealthArmLeft = i;
    p.default.HealthArmRight = i;
    p.default.EnergyMax = i;
    p.default.Energy = i;
}

simulated event _PreTravel()
{
    SetHighDefaults(player());
}

function CapHealth(out int health, int d)
{
    health = Min(health, d);
}

simulated function FirstEntry()
{
    if((dxr.dxInfo.missionNumber == 98 && dxr.flags.autosave != 5) || dxr.dxInfo.missionNumber == 0) { // restore health in intro unless hardcore, or if training
        player().RestoreAllHealth();
    }
}

static function PartialHeal(#var(PlayerPawn) p, int maxhealth)
{
    _PartialHeal(p.HealthHead, maxhealth);
    _PartialHeal(p.HealthTorso, maxhealth);
    _PartialHeal(p.HealthLegLeft, maxhealth);
    _PartialHeal(p.HealthLegRight, maxhealth);
    _PartialHeal(p.HealthArmLeft, maxhealth);
    _PartialHeal(p.HealthArmRight, maxhealth);
    p.GenerateTotalHealth();
}

static function _PartialHeal(out int health, int d)
{
    health = Clamp(health, d/2, d);
}
