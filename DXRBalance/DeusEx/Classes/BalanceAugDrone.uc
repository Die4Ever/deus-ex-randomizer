class BalanceAugDrone injects AugDrone;

function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();
    // description gets overwritten by language file, also DXRAugmentations reads from the default.Description
    default.Description = "Advanced nanofactories can assemble a spy drone upon demand which can then be remotely controlled by the agent until released or destroyed, at which a point a new drone will be assembled."
                            $ " Detonating the drone costs 10 energy. Further upgrades equip the spy drones with better armor and a one-shot EMP attack."
                            $ "|n|nTECH ONE: The drone can take little damage and has a very light EMP attack."
                            $ "|n|nTECH TWO: The drone can take minor damage and has a light EMP attack."
                            $ "|n|nTECH THREE: The drone can take moderate damage and has a medium EMP attack."
                            $ "|n|nTECH FOUR: The drone can take heavy damage and has a strong EMP attack.";
    Description = default.Description;
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
