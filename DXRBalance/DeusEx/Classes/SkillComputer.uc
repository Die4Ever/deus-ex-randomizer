class SkillComputer injects SkillComputer;

function UpdateBalance()
{
    local int i;

    if(class'MenuChoice_BalanceSkills'.static.IsEnabled()) {
        LevelValues[0] = 0.8;
        LevelValues[1] = 1;
        LevelValues[2] = 1.5;
        LevelValues[3] = 4.5;
        cost[0] = 1575;
        cost[1] = 2250;
        cost[2] = 3750;
    } else {
        LevelValues[0] = 0.8;// vanilla is 1, but it doesn't matter
        LevelValues[1] = 1;
        LevelValues[2] = 2;
        LevelValues[3] = 4;
        cost[0] = 1125;
        cost[1] = 2250;
        cost[2] = 3750;
    }

    for(i=0; i<ArrayCount(LevelValues); i++) {
        default.LevelValues[i] = LevelValues[i];
    }
    for(i=0; i<ArrayCount(cost); i++) {
        default.cost[i] = cost[i];
    }
}

// vanilla is 1, 1, 2, 4
defaultproperties
{
    LevelValues(0)=0.8
    LevelValues(1)=1
    LevelValues(2)=1.5
    LevelValues(3)=4.5
}
