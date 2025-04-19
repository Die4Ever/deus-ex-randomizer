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

    augDisplay = DeusExRootWindow(Player.rootWindow).hud.augDisplay;
    augDisplay.SetActiveVisionAug(self, Level, LevelValue, IsActive);
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
