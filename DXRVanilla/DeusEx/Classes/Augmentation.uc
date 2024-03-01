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
    if(class'MenuChoice_AutoAugs'.default.enabled) {
        bAutomatic = default.bAutomatic;
    }
    else {
        bAutomatic = false;
    }
}

simulated function TickUse()
{
    LastUsed = Level.TimeSeconds;
}

simulated function float GetEnergyRate()
{
    if(bAutomatic && LastUsed+5 < Level.TimeSeconds)
        return 0;
    return energyRate;
}

defaultproperties
{
    LastUsed=-100
}
