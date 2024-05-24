class BalanceAugDrone injects AugDrone;
// original values went from 10 to 50, but we also adjust the damage values in BalanceSpyDrone.uc
defaultproperties
{
    reconstructTime=1
    EnergyRate=20
    LevelValues(0)=30
    LevelValues(1)=50
    LevelValues(2)=70
    LevelValues(3)=100
}
