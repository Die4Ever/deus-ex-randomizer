class BuffTechGoggles injects TechGoggles;

function static float CalcDistance()
{
    return 320;
}

function static string CalcDescription()
{
    local string desc;
    desc = default.Description;
    if(class'MenuChoice_BalanceItems'.static.IsEnabled()) {
        desc = desc $ "|n|nSee-through walls distance: " $ int(CalcDistance()/16.0) $ " ft";
    }
    return desc;
}

function PostBeginPlay()
{
    Super.PostBeginPlay();

    if(class'MenuChoice_BalanceItems'.static.IsDisabled()) {
        Charge = class'TechGogglesInjBase'.default.Charge;
        return;
    }

    Description = CalcDescription();
}

function UpdateHUDDisplay(DeusExPlayer Player)
{
    local AugmentationDisplayWindow augDisplay;
    local float dist;

    if(class'MenuChoice_BalanceItems'.static.IsDisabled()) {
        Super.UpdateHUDDisplay(Player);
        return;
    }

    dist = CalcDistance();

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
    local AugmentationDisplayWindow augDisplay;

    if(class'MenuChoice_BalanceItems'.static.IsDisabled()) {
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
        augDisplay.visionLevelValue -= CalcDistance();
    }

    Super(ChargedPickup).ChargedPickupEnd(Player);
}

defaultproperties
{
    Charge=1000
}
