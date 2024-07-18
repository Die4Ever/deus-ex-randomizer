class DXRAugEMP injects AugEMP;

function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();
    // DXRando: AugEMP makes you immune to Scramble Grenades
    default.Description = "Nanoscale EMP generators partially protect individual nanites and reduce bioelectrical drain by canceling incoming pulses."
        $ "All levels make you immune to Scramble Grenades."
        $ "|n|nTECH ONE: Damage from EMP attacks is reduced slightly."
        $ "|n|nTECH TWO: Damage from EMP attacks is reduced moderately."
        $ "|n|nTECH THREE: Damage from EMP attacks is reduced significantly."
        $ "|n|nTECH FOUR: An agent is nearly invulnerable to damage from EMP attacks.";
    Description = default.Description;
}

defaultproperties
{
    bAutomatic=true
    LevelValues(0)=0.7
    LevelValues(1)=0.4
    LevelValues(2)=0.2
    LevelValues(3)=0
}
