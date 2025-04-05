class SkillEnviro injects SkillEnviro;

function UpdateBalance()
{
    local int i;

    if(class'MenuChoice_BalanceSkills'.static.IsEnabled()) {
        LevelValues[0] = 0.9;
        LevelValues[1] = 0.7;
        LevelValues[2] = 0.5;
        LevelValues[3] = 0.3;
        cost[0] = 600;
        cost[1] = 1215;
        cost[2] = 2025;
    } else {
        LevelValues[0] = 1;
        LevelValues[1] = 0.75;
        LevelValues[2] = 0.5;
        LevelValues[3] = 0.25;
        cost[0] = 675;
        cost[1] = 1350;
        cost[2] = 2250;
    }

    for(i=0; i<ArrayCount(LevelValues); i++) {
        default.LevelValues[i] = LevelValues[i];
    }
    for(i=0; i<ArrayCount(cost); i++) {
        default.cost[i] = cost[i];
    }
}

defaultproperties
{
    LevelValues(0)=0.9
    LevelValues(1)=0.7
    LevelValues(2)=0.5
    LevelValues(3)=0.3
}
