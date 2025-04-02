class SkillDemolition injects SkillDemolition;

function UpdateBalance()
{
    local int i;

    if(class'MenuChoice_BalanceSkills'.static.IsEnabled()) {
        cost[0] = 720;
        cost[1] = 1440;
        cost[2] = 2400;
    } else {
        cost[0] = 900;
        cost[1] = 1800;
        cost[2] = 3000;
    }

    for(i=0; i<ArrayCount(LevelValues); i++) {
        default.LevelValues[i] = LevelValues[i];
    }
    for(i=0; i<ArrayCount(cost); i++) {
        default.cost[i] = cost[i];
    }
}

