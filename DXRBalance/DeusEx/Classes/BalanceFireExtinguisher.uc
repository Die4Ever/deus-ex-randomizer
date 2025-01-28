class BalanceFireExtinguisher injects FireExtinguisher;

function Timer()
{
    if(class'DXRFlags'.default.bZeroRandoPure) {
        Super.Timer();
    } else {
        UseOnce();
    }
}

function BeginPlay()
{
    if(class'DXRFlags'.default.bZeroRandoPure) {
        maxCopies = 1;
        bCanHaveMultipleCopies = false;
    } else {
        maxCopies = 5;
        bCanHaveMultipleCopies = true;
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
