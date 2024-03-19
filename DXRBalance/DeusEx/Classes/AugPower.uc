class DXRAugPower injects AugPower;

simulated function SetAutomatic()
{
    Super.SetAutomatic();

    // HACK: a little wonky if you change the setting mid-game, but otherwise works
    energyRate = default.energyRate;
    if(class'MenuChoice_AutoAugs'.default.enabled) {
        bAlwaysActive = default.bAlwaysActive;
        if(bAlwaysActive) {
            energyRate = 0;
        }
    }
    else {
        bAlwaysActive = false;
    }
}

defaultproperties
{
    bAlwaysActive=true
}
