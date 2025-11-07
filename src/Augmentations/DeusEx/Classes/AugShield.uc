#compileif injections
class DXRAugShield injects AugShield;

function UpdateBalance()
{
    if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
        EnergyRate = 25;
        Level5Value = 0.05;
    } else {
        EnergyRate = 40;
        Level5Value = -1;
    }
    default.EnergyRate = EnergyRate;
    default.Level5Value = Level5Value;

    // Description adjusted to also include "explosive" damage, which is a vanilla behaviour (in other words, this isn't really a *balance* change, just a correction).
    // Localization files overwrite the Description if placed in the defaultproperties, so do it here instead.  Update the default too, because that's what the aug screen pulls from.
    Description="Polyanilene capacitors below the skin absorb heat and electricity, reducing the damage received from flame, electrical, explosive, and plasma attacks."$"|n|nTECH ONE: Damage from energy attacks is reduced slightly.|n|nTECH TWO: Damage from energy attacks is reduced moderately."$"|n|nTECH THREE: Damage from energy attacks is reduced significantly.|n|nTECH FOUR: An agent is nearly invulnerable to damage from energy attacks.";
    Default.Description = Description;
}

// vanilla level 1 is 0.80 (20%) but rounding causes it to show as 19%, same issue with level 2
// vanilla EnergyRate is 40, mpEnergyDrain is 25
defaultproperties
{
    bAutomatic=true
    EnergyRate=25
    LevelValues(0)=0.799999
    LevelValues(1)=0.599999
    Level5Value=0.05
}
