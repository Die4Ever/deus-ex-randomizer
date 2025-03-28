class BalanceAugDrone injects AugDrone;

function Reset()
{
    //Don't actually reset if the aug is already inactive
    if (!bIsActive) return;

    Player.spyDroneLevel = CurrentLevel;
    Player.spyDroneLevelValue = GetAugLevelValue();

    Human(Player).SetDroneStats();
}

function UpdateBalance()
{
    local int i;
    if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
        reconstructTime=1;
        EnergyRate=20;
        LevelValues[0]=30;
        LevelValues[1]=50;
        LevelValues[2]=70;
        LevelValues[3]=100;
        Description = "Advanced nanofactories can assemble a spy drone upon demand which can then be remotely controlled by the agent until released or destroyed, at which a point a new drone will be assembled."
                        $ " Detonating the drone costs 10 energy. Further upgrades equip the spy drones with better armor and a one-shot EMP attack."
                        $ "|n|nTECH ONE: The drone is slow and has a very light EMP attack."
                        $ "|n|nTECH TWO: The drone is fast and has a light EMP attack."
                        $ "|n|nTECH THREE: The drone is very fast and has a medium EMP attack."
                        $ "|n|nTECH FOUR: The drone is extremely fast and has a strong EMP attack.";
    } else {
        reconstructTime=30;
        EnergyRate=150;
        LevelValues[0]=10;
        LevelValues[1]=20;
        LevelValues[2]=35;
        LevelValues[3]=50;
        Description = "Advanced nanofactories can assemble a spy drone upon demand which can then be remotely controlled by the agent until released or destroyed, at which a point a new drone will be assembled."
                        $ " Further upgrades equip the spy drones with better armor and a one-shot EMP attack."
                        $ "|n|nTECH ONE: The drone can take little damage and has a very light EMP attack."
                        $ "|n|nTECH TWO: The drone can take minor damage and has a light EMP attack."
                        $ "|n|nTECH THREE: The drone can take moderate damage and has a medium EMP attack."
                        $ "|n|nTECH FOUR: The drone can take heavy damage and has a strong EMP attack.";
    }
    default.reconstructTime=reconstructTime;
    default.EnergyRate=EnergyRate;
    for(i=0; i<ArrayCount(LevelValues); i++) {
        default.LevelValues[i] = LevelValues[i];
    }
    default.Description = Description;
}

// original values went from 10 to 50, but we also adjust the multipliers in BalancePlayer.uc
defaultproperties
{
    reconstructTime=1
    EnergyRate=20
    LevelValues(0)=30
    LevelValues(1)=50
    LevelValues(2)=70
    LevelValues(3)=100
}
