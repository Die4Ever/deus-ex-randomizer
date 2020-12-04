class BalanceFireExtinguisher injects FireExtinguisher;

function Timer()
{
    UseOnce();
}

simulated function PreBeginPlay()
{
    Super.PreBeginPlay();
    maxCopies=default.maxCopies;
}

defaultproperties
{
    maxCopies=20
    bCanHaveMultipleCopies=True
}
