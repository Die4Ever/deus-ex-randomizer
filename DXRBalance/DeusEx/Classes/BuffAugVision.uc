class BuffAugVision injects AugVision;

state Active
{
Begin:
}

simulated function SetVisionAugStatus(int Level, int LevelValue, bool IsActive)
{
    local AugmentationDisplayWindow augDisplay;

    augDisplay = DeusExRootWindow(Player.rootWindow).hud.augDisplay;
    if (IsActive)
    {
        if (++augDisplay.activeCount <= 1) {
            augDisplay.activeCount = 1;
            augDisplay.bVisionActive = True;
            augDisplay.visionLevel = Level + 1;
            augDisplay.visionLevelValue = LevelValue;
        } else {
            augDisplay.visionLevel += Level + 1;
            augDisplay.visionLevelValue += LevelValue;
        }
    }
    else
    {
        if (--augDisplay.activeCount <= 0) {
            augDisplay.activeCount = 0;
            augDisplay.bVisionActive = False;
            augDisplay.visionLevel = 0;
            augDisplay.visionLevelValue = 0;
        } else {
            augDisplay.visionLevel -= Level + 1;
            augDisplay.visionLevelValue -= LevelValue;
        }
        augDisplay.visionBlinder = None;
    }
}

// level value is feet*16
defaultproperties
{
    LevelValues(0)=160
    LevelValues(1)=800
    LevelValues(2)=1600
    LevelValues(3)=3200
}
