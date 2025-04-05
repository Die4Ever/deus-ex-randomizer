class SkillSwimming injects SkillSwimming;

function UpdateBalance()
{
    local int i;

    if(class'MenuChoice_BalanceSkills'.static.IsEnabled()) {
        cost[0] = 540;
        cost[1] = 1080;
        cost[2] = 1800;
    } else {
        cost[0] = 675;
        cost[1] = 1350;
        cost[2] = 2250;
    }

    for(i=0; i<ArrayCount(cost); i++) {
        default.cost[i] = cost[i];
    }
}
