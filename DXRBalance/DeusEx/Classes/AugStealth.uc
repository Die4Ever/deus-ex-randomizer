class AugStealth injects AugStealth;

function UpdateBalance()
{
    local int i;
    if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
        LevelValues[0] = 0.7;
        LevelValues[1] = 0.5;
        LevelValues[2] = 0.25;
        LevelValues[3] = -0.01; // max level should usually be 0% when randomized
    } else {
        LevelValues[0] = 0.75;
        LevelValues[1] = 0.5;
        LevelValues[2] = 0.25;
        LevelValues[3] = 0.0;
    }
    for(i=0; i<ArrayCount(LevelValues); i++) {
        default.LevelValues[i] = LevelValues[i];
    }
}

defaultproperties
{
    EnergyRate=40.000000
    LevelValues(0)=0.7
    LevelValues(1)=0.5
    LevelValues(2)=0.25
    LevelValues(3)=-0.01
}
