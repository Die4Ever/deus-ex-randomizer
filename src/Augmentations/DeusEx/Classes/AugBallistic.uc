#compileif injections
class DXRAugBallistic injects AugBallistic;

function UpdateBalance()
{
    if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
        Level5Value = 0.15;
    } else {
        Level5Value = -1;
    }
    default.Level5Value = Level5Value;
}

// vanilla level 1 is 0.80 (20%) but rounding causes it to show as 19%
defaultproperties
{
    bAutomatic=true
    LevelValues(0)=0.799999
    Level5Value=0.15
}
