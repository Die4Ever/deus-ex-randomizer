class BuffTechGoggles injects TechGoggles;

function UpdateHUDDisplay(DeusExPlayer Player)
{
    Super.UpdateHUDDisplay(Player);
    DeusExRootWindow(Player.rootWindow).hud.augDisplay.visionLevel = 1;
    DeusExRootWindow(Player.rootWindow).hud.augDisplay.visionLevelValue = 800;
}
