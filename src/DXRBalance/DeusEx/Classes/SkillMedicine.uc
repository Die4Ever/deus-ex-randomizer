class SkillMedicine injects SkillMedicine;

function UpdateBalance()
{
    local int i;
    if(class'MenuChoice_BalanceSkills'.static.IsEnabled()) {
        LevelValues[0]=1.0;
        LevelValues[1]=1.6667;
        LevelValues[2]=2.3334;
        LevelValues[3]=3.0;
    } else {
        LevelValues[0]=1.0;
        LevelValues[1]=2.0;
        LevelValues[2]=2.5;
        LevelValues[3]=3.0;
    }

    for(i=0; i<ArrayCount(LevelValues); i++) {
        default.LevelValues[i] = LevelValues[i];
    }
}

// LevelValues get multiplied by 30
defaultproperties
{
    LevelValues(0)=1.0
    LevelValues(1)=1.6667
    LevelValues(2)=2.3334
    LevelValues(3)=3.0
}

