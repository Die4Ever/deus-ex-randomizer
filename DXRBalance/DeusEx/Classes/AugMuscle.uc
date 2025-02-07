class DXRAugMuscle injects AugMuscle;

simulated function int GetClassLevel()
{
    if(MaxLevel == 3 && bHasIt && bIsActive) {
        return CurrentLevel;
    } else if (bHasIt && bIsActive) {
        // we squished the AugMuscle levels to make it more useful, and some things use the level instead of the strength
        return CurrentLevel * 3;// aug levels start with 0
    }
    else
        return -1;
}

function UpdateBalance()
{
    if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
        MaxLevel = 1;
        LevelValues[0] = 1.25;
        LevelValues[1] = 2;
        // description gets overwritten by language file, also DXRAugmentations reads from the default.Description
        Description = "Muscle strength is amplified with ionic polymeric gel myofibrils that allow the agent to push and lift extraordinarily heavy objects."
                        $ "|n|nTECH ONE: Strength is increased slightly.|n|nTECH TWO: An agent is inhumanly strong.";
    } else {
        MaxLevel = 3;
        LevelValues[0] = 1.25;
        LevelValues[1] = 1.5;
        Description = "Muscle strength is amplified with ionic polymeric gel myofibrils that allow the agent to push and lift extraordinarily heavy objects."
                        $ "|n|nTECH ONE: Strength is increased slightly.|n|nTECH TWO: Strength is increased moderately."
                        $ "|n|nTECH THREE: Strength is increased significantly.|n|nTECH FOUR: An agent is inhumanly strong.";
    }
    default.MaxLevel = MaxLevel;
    default.LevelValues[0] = LevelValues[0];
    default.LevelValues[1] = LevelValues[1];
    default.Description = Description;
}

// LevelValues only affect throwing velocity in vanilla, and in DXRando also DoJump
// otherwise vanilla uses GetClassLevel() + 2
defaultproperties
{
    MaxLevel=1
    LevelValues(0)=1.25
    LevelValues(1)=2
}
