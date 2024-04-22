class DXRAugmentation merges Augmentation;

var float LastUsed;
var float AutoLength;
var float AutoEnergyMult;

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
            energyRate = default.energyRate * AutoEnergyMult;
        }
    }
    else {
        bAutomatic = false;
    }
}

simulated function bool IsTicked()
{
    return (bAutomatic==false && bIsActive)
        || (bAutomatic && bIsActive && LastUsed+AutoLength > Level.TimeSeconds && Player.Energy > 0);
}

simulated function TickUse()
{
    if(bAutomatic && !IsTicked()) {
        Player.Energy -= energyRate/60.0;
        if(Player.Energy <= 0) {
            Player.Energy = 0;
            return;// don't update the LastUsed
        } else {
            Player.PlaySound(ActivateSound, SLOT_None, 0.75);
            Player.AmbientSound = LoopSound;
        }
    }
    LastUsed = Level.TimeSeconds;
}

simulated function float GetEnergyRate()
{
    if(bAutomatic && !IsTicked()) {
        if (Player.AmbientSound == LoopSound && Player.AugmentationSystem.NumAugsActive() == 0) {
            Player.PlaySound(DeactivateSound, SLOT_None, 0.75);
            Player.AmbientSound = None;
        }
        return 0;
    }
    return energyRate;
}

// fix hum sounds for auto augs
function Activate()
{
    local Sound oldAmbient;

    oldAmbient = Player.AmbientSound;

    _Activate();// call the super, but this is merges

    if(bAutomatic && oldAmbient != LoopSound && Player.AmbientSound == LoopSound)
        Player.AmbientSound = oldAmbient;
}

function Deactivate()
{
    _Deactivate();// call the super, but this is merges
    if(bAutomatic) {
        LastUsed = FMin(LastUsed, Level.TimeSeconds - AutoLength);
    }
}


// DXRando: don't disable auto augs when upgrading
function bool IncLevel()
{
    if ( !CanBeUpgraded() )
    {
        Player.ClientMessage(Sprintf(AugAlreadyHave, AugmentationName));
        return False;
    }

    if (bIsActive && AugDrone(self) != None) {
        Deactivate();
        Activate();
    }

    CurrentLevel++;

    Player.ClientMessage(Sprintf(AugNowHave, AugmentationName, CurrentLevel + 1));
}


defaultproperties
{
    LastUsed=-100
    AutoLength=5
    AutoEnergyMult=2
}
