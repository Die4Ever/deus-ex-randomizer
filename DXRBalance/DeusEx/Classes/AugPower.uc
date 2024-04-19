class DXRAugPower injects AugPower;

simulated function SetAutomatic()
{
    local DXRAugmentations raugs;
    local int i;

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

    // power recirc is OP when it's free, RandoAug reads from defaults
    if(energyRate == 0) {
        default.LevelValues[0] = 0.92;
        default.LevelValues[1] = 0.85;
        default.LevelValues[2] = 0.7;
        default.LevelValues[3] = 0.5;
    } else {
        default.LevelValues[0] = 0.9;
        default.LevelValues[1] = 0.8;
        default.LevelValues[2] = 0.6;
        default.LevelValues[3] = 0.4;
    }
    for(i=0; i<ArrayCount(LevelValues); i++) {
        LevelValues[i] = default.LevelValues[i];
    }

    if(player != None)
        raugs = DXRAugmentations(Human(player).DXRFindModule(class'DXRAugmentations'));
    if(raugs != None)
        raugs.RandoAug(self);
}

defaultproperties
{
    bAlwaysActive=true
}
