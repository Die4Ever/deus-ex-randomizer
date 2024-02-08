class DXRAugmentation merges Augmentation;

var float LastUsed;

function PostBeginPlay()
{
    local DXRAugmentations a;
    Super.PostBeginPlay();

    // TODO: read config value for bAutomatic
    // the button to enable disable can set the config, but also search all Augmentations and set bAutomatic to their default or to false

    foreach AllActors(class'DXRAugmentations', a) {
        a.RandoAug(self);
        break;
    }
}

simulated function TickUse()
{
    LastUsed = 5;
}

simulated function float GetEnergyRate()
{
    if(bAutomatic && LastUsed <= 0)
        return 0;
    return energyRate;
}

simulated function Tick(float DeltaTime)
{
   Super.Tick(DeltaTime);
   if(LastUsed > 0) LastUsed -= DeltaTime;
}
