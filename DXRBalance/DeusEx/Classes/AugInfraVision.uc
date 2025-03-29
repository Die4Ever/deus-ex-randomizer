class AugInfraVision extends AugVision;

simulated function SetVisionAugStatus(int Level, int LevelValue, bool IsActive)
{
    local AugmentationDisplayWindow augDisplay;

    Super.SetVisionAugStatus(Level, LevelValue, IsActive);

    augDisplay = DeusExRootWindow(Player.rootWindow).hud.augDisplay;
    if (IsActive)
    {
        augDisplay.bThermalVision = true;
    }
    else
    {
        augDisplay.bThermalVision = false;
    }
}

// level value is feet*16, 112 is MaxFrobDistance (7 feet)
defaultproperties
{
    LevelValues(0)=240
    maxLevel=1
    energyRate=0
    AugmentationName="Infravision"
    Description="Infravision allows an agent to see people, robots, and computers through walls."
}
