class DXRAugMuscle injects AugMuscle;

function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();
    // description gets overwritten by language file, also DXRAugmentations reads from the default.Description
    default.Description = "Muscle strength is amplified with ionic polymeric gel myofibrils that allow the agent to push and lift extraordinarily heavy objects."
                            $ "|n|nTECH ONE: Strength is increased slightly.|n|nTECH TWO: An agent is inhumanly strong.";
    Description = default.Description;
}

simulated function int GetClassLevel()
{
    if (bHasIt && bIsActive)
    {
        // we squished the AugMuscle levels to make it more useful, and some things use the level instead of the strength
        return CurrentLevel * 3;// aug levels start with 0
    }
    else
        return -1;
}

// LevelValues only affect throwing velocity in vanilla, and in DXRando also DoJump
// otherwise vanilla uses GetClassLevel() + 2
defaultproperties
{
    MaxLevel=1
    LevelValues(0)=1.25
    LevelValues(1)=2
}
