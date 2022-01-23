class BuffAugVision injects AugVision;

state Active
{
Begin:
}

simulated function SetVisionAugStatus(int Level, int LevelValue, bool IsActive)
{
    Super.SetVisionAugStatus(Level, LevelValue, IsActive);
    DeusExRootWindow(Player.rootWindow).hud.augDisplay.visionLevel = Level + 1;
    DeusExRootWindow(Player.rootWindow).hud.augDisplay.visionLevelValue = LevelValue;
}

// level value is feet*16
defaultproperties
{
    LevelValues(0)=160
    LevelValues(1)=800
    LevelValues(2)=1600
    LevelValues(3)=3200
}
