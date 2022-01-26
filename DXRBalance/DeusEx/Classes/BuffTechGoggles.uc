class BuffTechGoggles injects TechGoggles;

function static float CalcDistance(AugVision aug)
{
    local float str;

    str = class'AugVision'.default.LevelValues[0] + class'AugVision'.default.LevelValues[1];
    if(aug != None) {
        str = aug.LevelValues[0] + aug.LevelValues[1];
    }
    str /= 2.0;
    return str;
}

function static string CalcDescription(AugVision aug)
{
    local string desc;
    desc = default.Description $ "|n|nSee-through walls distance: ";
    desc = desc $ int(CalcDistance(aug)/16.0) $ " ft";
    return desc;
}

function PostBeginPlay()
{
    local AugVision aug;
    Super.PostBeginPlay();

    foreach AllActors(class'AugVision', aug) {
        Description = CalcDescription(aug);
        return;
    }

    Description = CalcDescription(None);
}

function UpdateHUDDisplay(DeusExPlayer Player)
{
    local AugVision aug;

    Super.UpdateHUDDisplay(Player);
    DeusExRootWindow(Player.rootWindow).hud.augDisplay.visionLevel = 1;

    aug = AugVision(Player.AugmentationSystem.GetAug(class'AugVision'));
    DeusExRootWindow(Player.rootWindow).hud.augDisplay.visionLevelValue = CalcDistance(aug);
}
