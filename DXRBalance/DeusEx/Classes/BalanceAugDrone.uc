class BalanceAugDrone injects AugDrone;
// original values went from 10 to 50, but we also adjust the damage values in BalanceSpyDrone.uc
defaultproperties
{
    reconstructTime=1
    EnergyRate=100
    LevelValues(0)=50
    LevelValues(1)=75
    LevelValues(2)=100
    LevelValues(3)=150
}
