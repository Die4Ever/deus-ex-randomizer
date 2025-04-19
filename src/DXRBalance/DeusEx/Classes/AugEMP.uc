class DXRAugEMP injects AugEMP;

function UpdateBalance()
{
    local int i;
    if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
        LevelValues[0] = 0.7;
        LevelValues[1] = 0.4;
        LevelValues[2] = 0.2;
        LevelValues[3] = 0;
    } else {
        LevelValues[0] = 0.75;
        LevelValues[1] = 0.5;
        LevelValues[2] = 0.25;
        LevelValues[3] = 0;
    }
    for(i=0; i<ArrayCount(LevelValues); i++) {
        default.LevelValues[i] = LevelValues[i];
    }

    // DXRando: AugEMP makes you immune to Scramble Grenades
    Description = "Nanoscale EMP generators partially protect individual nanites and reduce bioelectrical drain by canceling incoming pulses.  ";
    if(class'MenuChoice_BalanceEtc'.static.IsEnabled()) {
        Description = Description $ "All levels make you immune to Scramble Grenades."
            $ "|n|nTECH ONE: Damage from EMP and electric attacks is reduced slightly."
            $ "|n|nTECH TWO: Damage from EMP and electric attacks is reduced moderately."
            $ "|n|nTECH THREE: Damage from EMP and electric attacks is reduced significantly."
            $ "|n|nTECH FOUR: An agent is nearly invulnerable to damage from EMP and electric attacks.";
    } else {
        Description = Description $ "|n|nTECH ONE: Damage from EMP attacks is reduced slightly."
            $ "|n|nTECH TWO: Damage from EMP attacks is reduced moderately."
            $ "|n|nTECH THREE: Damage from EMP attacks is reduced significantly."
            $ "|n|nTECH FOUR: An agent is nearly invulnerable to damage from EMP attacks.";
    }
    default.Description = Description;
}

defaultproperties
{
    bAutomatic=true
    AutoLength=1
    AutoEnergyMult=1
    LevelValues(0)=0.7
    LevelValues(1)=0.4
    LevelValues(2)=0.2
    LevelValues(3)=0
}
