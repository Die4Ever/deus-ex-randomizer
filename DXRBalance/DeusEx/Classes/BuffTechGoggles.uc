class BuffTechGoggles injects TechGoggles;

function static float CalcDistance(AugVision aug)
{
    if(aug != None) {
        return aug.LevelValues[1];
    }
    return class'AugVision'.default.LevelValues[1];
}

function static string CalcDescription(AugVision aug)
{
    local string desc;
    desc = default.Description;
    if(!class'DXRFlags'.default.bZeroRandoPure) {
        desc = desc $ "|n|nSee-through walls distance: " $ int(CalcDistance(aug)/16.0) $ " ft";
    }
    return desc;
}

function PostBeginPlay()
{
    local AugVision aug;
    Super.PostBeginPlay();

    if(class'DXRFlags'.default.bZeroRandoPure) {
        Charge = class'TechGogglesInjBase'.default.Charge;
        return;
    }

    foreach AllActors(class'AugVision', aug) {
        Description = CalcDescription(aug);
        return;
    }

    Description = CalcDescription(None);
}

function UpdateHUDDisplay(DeusExPlayer Player)
{
    local AugVision aug;
    local AugmentationDisplayWindow augDisplay;
    local float dist;

    if(class'DXRFlags'.default.bZeroRandoPure) {
        Super.UpdateHUDDisplay(Player);
        return;
    }

    aug = AugVision(Player.AugmentationSystem.FindAugmentation(class'AugVision'));
    dist = CalcDistance(aug);

    augDisplay = DeusExRootWindow(Player.rootWindow).hud.augDisplay;
    if ((augDisplay.activeCount == 0) && (IsActive())) {
        augDisplay.activeCount++;
        log("WARNING: "$self$".UpdateHUDDisplay augDisplay.activeCount == 0");
    }

    if(augDisplay.activeCount == 1) {
        augDisplay.bVisionActive = True;
        augDisplay.visionLevel = 1;
        augDisplay.visionLevelValue = dist;
    } else {
        augDisplay.bVisionActive = True;
        augDisplay.visionLevel += 1;
        augDisplay.visionLevelValue += dist;
    }
}

function ChargedPickupEnd(DeusExPlayer Player)
{
    local AugVision aug;
    local AugmentationDisplayWindow augDisplay;

    if(class'DXRFlags'.default.bZeroRandoPure) {
        Super.ChargedPickupEnd(Player);
        return;
    }

    augDisplay = DeusExRootWindow(Player.rootWindow).hud.augDisplay;
    if (--augDisplay.activeCount <= 0) {
        augDisplay.activeCount = 0;
        augDisplay.bVisionActive = False;
        augDisplay.visionLevel = 0;
        augDisplay.visionLevelValue = 0;
        augDisplay.visionBlinder = None;
    } else {
        augDisplay.visionLevel -= 1;
        aug = AugVision(Player.AugmentationSystem.FindAugmentation(class'AugVision'));
        augDisplay.visionLevelValue -= CalcDistance(aug);
    }

    Super(ChargedPickup).ChargedPickupEnd(Player);
}

defaultproperties
{
    Charge=1000
}
