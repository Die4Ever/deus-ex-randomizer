class DXRAugTarget injects AugTarget;

simulated function TickUse()
{
    if(DeusExRootWindow(Player.rootWindow).winCount > 0)
        return; // don't tick while reading item descriptions
    if (DeusExWeapon(Player.inHand)==None){
        return; // don't tick unless you're holding a weapon
    }
    Super.TickUse();
    SetTargetingAugStatus(CurrentLevel, bIsActive);// we're enabled
}

simulated function float GetEnergyRate()
{
    SetTargetingAugStatus(CurrentLevel, bIsActive && IsTicked());
    return Super.GetEnergyRate();
}

simulated function SetTargetingAugStatus(int Level, bool IsActive)
{
    if(!IsTicked()) IsActive=false;

    DeusExRootWindow(Player.rootWindow).hud.augDisplay.bTargetActive = IsActive;
    DeusExRootWindow(Player.rootWindow).hud.augDisplay.targetLevel = Level;
}

function UpdateBalance()
{
    if(class'MenuChoice_BalanceAugs'.static.IsEnabled()) {
        Level5Value=-0.25;
    } else {
        Level5Value=-1;
    }
    default.Level5Value = Level5Value;
}

defaultproperties
{
    bAutomatic=true
    AutoLength=1
    Level5Value=-0.25
}
