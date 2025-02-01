class SkillEnviro injects SkillEnviro;

function BeginPlay()
{
    local int i;

    if(class'MenuChoice_BalanceSkills'.static.IsEnabled()) {
        LevelValues[0] = 0.9;
        LevelValues[1] = 0.7;
        LevelValues[2] = 0.5;
        LevelValues[3] = 0.3;
    } else {
        LevelValues[0] = 1;
        LevelValues[1] = 0.75;
        LevelValues[2] = 0.5;
        LevelValues[3] = 0.25;
    }

    for(i=0; i<ArrayCount(LevelValues); i++) {
        default.LevelValues[i] = LevelValues[i];
    }
    Super.BeginPlay();
}

defaultproperties
{
    LevelValues(0)=0.9
    LevelValues(1)=0.7
    LevelValues(2)=0.5
    LevelValues(3)=0.3
}
