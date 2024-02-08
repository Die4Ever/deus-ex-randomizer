class AugmentationManager merges AugmentationManager;
// merges because the game validates the superclass

function DeactivateAll()
{
    local Augmentation anAug;

    anAug = FirstAug;
    while(anAug != None)
    {
        if (anAug.bIsActive && anAug.GetEnergyRate() > 0)
            anAug.Deactivate();
        anAug = anAug.next;
    }
}

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
    local float energyUse, energyMult;
    local Augmentation anAug;

    energyUse = 0;
    energyMult = 1.0;

    anAug = FirstAug;
    while(anAug != None)
    {
        if (anAug.IsA('AugPower') && anAug.bHasIt)// TODO: set AugPower.bAlwaysActive to true
            energyMult = anAug.LevelValues[anAug.CurrentLevel];

        if (anAug.bHasIt && anAug.bIsActive)
        {
            energyUse += ((anAug.GetEnergyRate()/60) * deltaTime);
        }
        anAug = anAug.next;
    }

    // check for the power augmentation
    energyUse *= energyMult;

    return energyUse;
}
