#compileif injections
class DXRAugPower injects AugPower;

simulated function UpdateBalance()
{
    local int i;

    // HACK: a little wonky if you change the setting mid-game, but otherwise works
    energyRate = default.energyRate;
    if(class'MenuChoice_AutoAugs'.static.IsEnabled()) {
        bAlwaysActive = default.bAlwaysActive;
        if(bAlwaysActive) {
            energyRate = 0;
        }
    }
    else {
        bAlwaysActive = false;
    }

    // power recirc is OP when it's free, RandoAug reads from defaults
    if(energyRate == 0) {
        LevelValues[0] = 0.92;
        LevelValues[1] = 0.85;
        LevelValues[2] = 0.75;
        LevelValues[3] = 0.6;
    } else {
        LevelValues[0] = 0.9;
        LevelValues[1] = 0.8;
        LevelValues[2] = 0.6;
        LevelValues[3] = 0.4;
    }
    for(i=0; i<ArrayCount(LevelValues); i++) {
        default.LevelValues[i] = LevelValues[i];
    }
}

defaultproperties
{
    bAlwaysActive=true
}
