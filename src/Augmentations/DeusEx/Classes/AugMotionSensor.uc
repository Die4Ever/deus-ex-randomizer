#compileif injections
class AugMotionSensor extends AugVision;

simulated function SetVisionAugStatus(int Level, int LevelValue, bool IsActive)
{
    local AugmentationDisplayWindow augDisplay;

    Super.SetVisionAugStatus(Level, LevelValue, IsActive);

    augDisplay = DeusExRootWindow(Player.rootWindow).hud.augDisplay;
    if (IsActive)
    {
        augDisplay.bMotionSensor = true;
    }
    else
    {
        augDisplay.bMotionSensor = false;
    }
}

// level value is feet*16, 112 is MaxFrobDistance (7 feet)
defaultproperties
{
    Icon=Texture'AugIconMotionSensor'
    smallIcon=Texture'AugIconMotionSensor_Small'
    LevelValues(0)=320
    maxLevel=0
    energyRate=0
    AugmentationName="Motion Sensor"
    Description="Motion Sensor allows an agent to see moving things through walls."
}
