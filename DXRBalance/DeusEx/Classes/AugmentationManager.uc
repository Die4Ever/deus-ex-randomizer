class AugmentationManager merges AugmentationManager;
// merges because the game validates the superclass

function Augmentation GetAugByKey(int keyNum)
{
    local Augmentation anAug;

    if ((keyNum < 0) || (keyNum > 9))
        return None;

    anAug = FirstAug;
    while(anAug != None)
    {
        if ((anAug.HotKeyNum - 3 == keyNum) && (anAug.bHasIt))
            return anAug;

        anAug = anAug.next;
    }

    return None;
}

simulated function Augmentation GetAug(class<Augmentation> AugClass)
{
    local Augmentation anAug;

    anAug = FirstAug;
    while(anAug != None)
    {
        if (anAug.Class == augClass)
            return anAug;
        anAug = anAug.next;
    }

    return None;
}

// ----------------------------------------------------------------------
// GetAugLevelValue()
//
// takes a class instead of being called by actual augmentation, modified for automatic augs
// ----------------------------------------------------------------------

simulated function float GetAugLevelValue(class<Augmentation> AugClass)
{
    local Augmentation anAug;
    local float retval;

    retval = 0;

    anAug = FirstAug;
    while(anAug != None)
    {
        if (anAug.Class == augClass)
        {
            if (anAug.bHasIt && anAug.bIsActive) {
                anAug.TickUse();
                return anAug.LevelValues[anAug.CurrentLevel];
            }
            else
                return -1.0;
        }

        anAug = anAug.next;
    }

    return -1.0;
}

// ----------------------------------------------------------------------
// CalcEnergyUse()
//
// Calculates energy use for all active augmentations, modified for automatic power recirc
// ----------------------------------------------------------------------

simulated function Float CalcEnergyUse(float deltaTime)
{
    local float f, energyUse, energyMult;
    local Augmentation anAug, augBoost;
    local bool bBoosting;

    energyUse = 0;
    energyMult = 1.0;

    anAug = FirstAug;
    while(anAug != None)
    {
        if (anAug.IsA('AugPower') && anAug.bHasIt)// TODO: set AugPower.bAlwaysActive to true
            energyMult = anAug.LevelValues[anAug.CurrentLevel];

        if (anAug.bHasIt && anAug.bIsActive)
        {
            if (AugHeartLung(anAug) != None) {
                augBoost = AnAug;
            }
            f = ((anAug.GetEnergyRate()/60) * deltaTime);
            if(f > 0 && anAug.bBoosted) {
                bBoosting = true;
            }
            energyUse += f;
        }
        anAug = anAug.next;
    }

    if(bBoosting) {
        f = (augBoost.GetEnergyRate()/60) * deltaTime;// check if it wasn't using energy yet
        augBoost.TickUse();
        if(f == 0) { // add in its energy usage if this is the first tick
            f = (augBoost.GetEnergyRate()/60) * deltaTime;
            energyUse += f;
        }
    }

    // check for the power augmentation
    energyUse *= energyMult;

    return energyUse;
}
