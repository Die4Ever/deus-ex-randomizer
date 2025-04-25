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
        default.Charge = 500;
        Charge = default.Charge;
        return;
    } else {
        default.Charge = 1000;
        Charge = default.Charge;
    }

    Description = CalcDescription();
}

function UpdateHUDDisplay(DeusExPlayer Player)
{
    local AugmentationDisplayWindow augDisplay;
    augDisplay = DeusExRootWindow(Player.rootWindow).hud.augDisplay;
    augDisplay.SetActiveVisionAug(None, 1, CalcDistance(), true);
}

function ChargedPickupEnd(DeusExPlayer Player)
{
    local AugmentationDisplayWindow augDisplay;
    augDisplay = DeusExRootWindow(Player.rootWindow).hud.augDisplay;
    augDisplay.SetActiveVisionAug(None, 1, CalcDistance(), false);
    Super(ChargedPickup).ChargedPickupEnd(Player);
}

defaultproperties
{
    Charge=1000
}
