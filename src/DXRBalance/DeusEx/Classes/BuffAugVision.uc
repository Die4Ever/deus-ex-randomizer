class BuffAugVision injects AugVision;

state Active
{
Begin: // make sure we refresh the status on loading saves
    SetVisionAugStatus(CurrentLevel, LevelValues[CurrentLevel], bIsActive);
}

function Activate()
{
    Super(Augmentation).Activate();
}

simulated function SetVisionAugStatus(int Level, int LevelValue, bool IsActive)
{
    local AugmentationDisplayWindow augDisplay;
    local int lvl;

    lvl = Level;
    if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) lvl++;

    augDisplay = DeusExRootWindow(Player.rootWindow).hud.augDisplay;
    if (IsActive)
    {
        if (++augDisplay.activeCount <= 1) {
            augDisplay.activeCount = 1;
            augDisplay.bVisionActive = True;
            augDisplay.visionLevel = lvl;
            augDisplay.visionLevelValue = LevelValue;
        } else {
            augDisplay.visionLevel += lvl;
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
            augDisplay.visionLevel -= lvl;
            augDisplay.visionLevelValue -= LevelValue;
        }
        augDisplay.visionBlinder = None;
    }
}

simulated function UpdateBalance()
{
    if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
        LevelValues[2]=640;
        LevelValues[3]=1600;
    } else {
        LevelValues[2]=320;
        LevelValues[3]=800;
    }
    default.LevelValues[2]=LevelValues[2];
    default.LevelValues[3]=LevelValues[3];
}

// level value is feet*16
defaultproperties
{
    LevelValues(0)=160
    LevelValues(1)=320
    LevelValues(2)=640
    LevelValues(3)=1600
}
