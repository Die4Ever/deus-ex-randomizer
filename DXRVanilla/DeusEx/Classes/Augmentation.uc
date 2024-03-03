class DXRAugmentation merges Augmentation;

var float LastUsed;

function PostBeginPlay()
{
    local DXRAugmentations a;
    Super.PostBeginPlay();

    SetAutomatic();

    foreach AllActors(class'DXRAugmentations', a) {
        a.RandoAug(self);
        break;
    }
}

simulated function SetAutomatic()
{
    if(default.bAutomatic) {
        // AugVision and AugMuscle have randomized energyRate, but they aren't bAutomatic anyways
        energyRate = default.energyRate;
    }

    if(class'MenuChoice_AutoAugs'.default.enabled) {
        bAutomatic = default.bAutomatic;
        if(bAutomatic) {
            energyRate = default.energyRate * 2;
        }
    }
    else {
        bAutomatic = false;
    }
}

simulated function TickUse()
{
    if(bAutomatic && LastUsed+5 < Level.TimeSeconds) {
        Player.Energy -= energyRate/60.0;
        if(Player.Energy <= 0) {
            Player.Energy = 0;
        }
    }
    LastUsed = Level.TimeSeconds;
}

simulated function float GetEnergyRate()
{
    if(bAutomatic && LastUsed+5 < Level.TimeSeconds && Player.Energy > 0)
        return 0;
    return energyRate;
}

defaultproperties
{
    LastUsed=-100
}
