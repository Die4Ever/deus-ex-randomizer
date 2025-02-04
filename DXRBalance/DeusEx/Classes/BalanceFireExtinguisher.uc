class BalanceFireExtinguisher injects FireExtinguisher;

function Timer()
{
    if(class'MenuChoice_BalanceItems'.static.IsEnabled()) {
        UseOnce();
    } else {
        Super.Timer();
    }
}

function BeginPlay()
{
    if(class'MenuChoice_BalanceItems'.static.IsEnabled()) {
        maxCopies = 5;
        bCanHaveMultipleCopies = true;
    } else {
        maxCopies = 1;
        bCanHaveMultipleCopies = false;
    }
    default.maxCopies = maxCopies;
    default.bCanHaveMultipleCopies = bCanHaveMultipleCopies;
    Super.BeginPlay();
}

defaultproperties
{
    maxCopies=5
    bCanHaveMultipleCopies=True
}
