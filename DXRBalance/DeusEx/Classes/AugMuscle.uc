class DXRAugMuscle injects AugMuscle;

function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();
    // description gets overwritten by language file, also DXRAugmentations reads from the default.Description
    default.Description = "Muscle strength is amplified with ionic polymeric gel myofibrils that allow the agent to push and lift extraordinarily heavy objects."
                            $ "|n|nTECH ONE: Strength is increased slightly.|n|nTECH TWO: An agent is inhumanly strong.";
    Description = default.Description;
}

// LevelValues only affect throwing velocity in vanilla, and in DXRando also DoJump
// otherwise vanilla uses GetClassLevel() + 2
defaultproperties
{
    MaxLevel=1
    LevelValues(0)=1.25
    LevelValues(1)=2
}
