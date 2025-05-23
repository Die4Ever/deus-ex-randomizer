class DXRAugmentation merges Augmentation;

var float LastUsed;
var float AutoLength;
var float AutoEnergyMult;
var float Level5Value;
var float activationCost;

function PostBeginPlay()
{
    local DXRAugmentations a;
    Super.PostBeginPlay();

    a = DXRAugmentations(class'DXRAugmentations'.static.Find(true));
    if(a!=None) {
        a.RandoAug(self);// RandoAug calls SetAutomatic()
    } else {
        SetAutomatic();
    }
}

simulated function UpdateBalance();

simulated function SetAutomatic()
{
    if(default.bAutomatic) {
        // AugVision and AugMuscle have randomized energyRate, but they aren't bAutomatic anyways
        energyRate = default.energyRate;
    }

    if(class'MenuChoice_AutoAugs'.static.IsEnabled()) {
        bAutomatic = default.bAutomatic;
        UpdateBalance(); // make sure energyRate is correct
        if(bAutomatic) {
            energyRate = default.energyRate * AutoEnergyMult;
        }
    }
    else {
        bAutomatic = false;
        UpdateBalance();
    }
}

simulated function float GetAugLevelValue()
{
    if (bHasIt && bIsActive) {
        TickUse();
        if(Player.Energy <= 0 && bAutomatic) {
            return -1.0;
        } else {
            if(CurrentLevel >= 4) return Level5Value;
            return LevelValues[CurrentLevel];
        }
    }
    else
        return -1.0;
}

simulated function float PreviewAugLevelValue()
{
    if (bHasIt && bIsActive) {
        // TickUse(); // no tick
        if(Player.Energy <= 0 && bAutomatic) {
            return -1.0;
        } else {
            if(CurrentLevel >= 4) return Level5Value;
            return LevelValues[CurrentLevel];
        }
    }
    else
        return -1.0;
}

simulated function int GetClassLevel()
{
    if (bHasIt && bIsActive)
        return CurrentLevel;
    else
        return -1;
}

function BoostAug(bool bBoostEnabled)
{
    local int maxBoostLevel;

    // DXRando: don't boost free augs because (0 * synth_heart_strength) == 0
    if (bBoostEnabled && energyRate > 0)
    {
        maxBoostLevel = MaxLevel;
        if(Level5Value != -1) maxBoostLevel++;

        if (bIsActive && !bBoosted && CurrentLevel < maxBoostLevel)
        {
            MaxLevel = maxBoostLevel;
            CurrentLevel++;
            bBoosted = True;
            Reset();
        }
    }
    else if (bBoosted && !bBoostEnabled)
    {
        CurrentLevel--;
        if(Level5Value != -1 && MaxLevel>default.MaxLevel) MaxLevel--;
        bBoosted = False;
        Reset();
    }
}

simulated function bool IsTicked()
{
    return (bAutomatic==false && bIsActive)
        || (bAutomatic && bIsActive && LastUsed+AutoLength > Level.TimeSeconds && Player.Energy > 0);
}

simulated function TickUse()
{
    local float useEnergy;

    if(bAutomatic && !IsTicked()) {
        // don't punish the player for auto aug turning off and immediately turning on again within the same one-second cycle
        if(LastUsed < Level.TimeSeconds-1 && Level.LevelAction == LEVACT_None) {
            useEnergy = energyRate/60.0 * GetEnergyMult();
        }
        if(Player.Energy <= useEnergy) {
            return;// don't update the LastUsed
        } else {
            Player.Energy -= useEnergy;
            Player.PlaySound(ActivateSound, SLOT_None, 0.75);
            Player.AmbientSound = LoopSound;
        }
    }
    LastUsed = Level.TimeSeconds;
}

simulated function float GetEnergyMult()
{
    local float mult;
    local Augmentation a;
    mult = 1;
    for(a=Player.AugmentationSystem.FirstAug; a!=None; a=a.next) {
        if (AugPower(a) != None && a.bHasIt && a.bIsActive)
            mult *= a.GetAugLevelValue();

        if (bBoosted && AugHeartLung(a) != None && a.bHasIt && a.bIsActive && a.bAutomatic)
            mult *= a.GetAugLevelValue();
    }
    return mult;
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

    if(activationCost > 0 && Level.LevelAction == LEVACT_None) {
        if(Player.Energy < activationCost) {
            Deactivate();
            return;
        } else {
            Player.Energy -= activationCost;
        }
    }

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

function Reset()
{
    local float oldLastUsed;

    //Don't actually reset if the aug is already inactive
    if (!bIsActive) return;

    // re-activate to adjust to upgrades/downgrades, without burning energy in a new TickUse()
    oldLastUsed = LastUsed;
    Deactivate();
    LastUsed = oldLastUsed;
    Activate();
}

// DXRando: don't disable auto augs when upgrading
function bool IncLevel()
{
    if ( !CanBeUpgraded() )
    {
        Player.ClientMessage(Sprintf(AugAlreadyHave, AugmentationName));
        return False;
    }

    CurrentLevel++;

    if (bIsActive) {
        Reset();
    }

    Player.ClientMessage(UpgradeMessage());
}

function string UpgradeMessage()
{
    local float before, after;
    local string s_before, s_after;

    before = LevelValues[CurrentLevel-1];
    if(CurrentLevel >= 4) after = Level5Value;
    else after = LevelValues[CurrentLevel];

    s_before = class'DXRAugmentations'.static.DescriptionLevelShort(self, CurrentLevel-1, before);
    s_after = class'DXRAugmentations'.static.DescriptionLevelShort(self, CurrentLevel, after);

    if(s_before=="" || s_after=="") {
        return Sprintf(AugNowHave, AugmentationName, CurrentLevel + 1);
    }
    return Sprintf(AugNowHave, AugmentationName, CurrentLevel + 1)
        $ " (from " $ s_before $ " to " $ s_after $ ")";
}

defaultproperties
{
    LastUsed=-100
    AutoLength=5
    AutoEnergyMult=2
    Level5Value=-1
}
