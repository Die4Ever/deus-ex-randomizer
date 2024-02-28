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
