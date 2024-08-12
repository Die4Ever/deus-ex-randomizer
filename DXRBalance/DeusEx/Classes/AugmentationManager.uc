class AugmentationManager merges AugmentationManager;
// merges because the game validates the superclass

function DeactivateAll()
{
    local Augmentation anAug;

    anAug = FirstAug;
    while(anAug != None)
    {
        if (anAug.bIsActive && anAug.GetEnergyRate() > 0 && !anAug.bAutomatic && !anAug.bAlwaysActive)
            anAug.Deactivate();
        anAug = anAug.next;
    }
}

function ActivateAllAutoAugs()
{
    local Augmentation anAug;

    if (player != None)
    {
        for(anAug = FirstAug; anAug != None; anAug = anAug.next)
        {
            if (anAug.bAutomatic)
                anAug.Activate();
        }
    }
}

simulated function int NumAugsActive()
{
    local Augmentation anAug;
    local int count;

    if (player == None)
        return 0;

    count = 0;
    for(anAug = FirstAug; anAug != None; anAug = anAug.next)
    {
        if (anAug.bHasIt && anAug.bIsActive && !anAug.bAlwaysActive) {
            if(anAug.bAutomatic && !anAug.IsTicked()) {
                continue;
            }
            count++;
        }
    }

    return count;
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
            return anAug.GetAugLevelValue();
        }

        anAug = anAug.next;
    }

    return -1.0;
}


// GetClassLevel DXRando: just squish the AugMuscle levels, this function is only used for AugMuscle, AugSpeed, and in multiplayer AugRadarTrans
simulated function int GetClassLevel(class<Augmentation> augClass)
{
    local Augmentation anAug;

    anAug = FirstAug;
    while(anAug != None)
    {
        if (anAug.Class == augClass)
        {
            return anAug.GetClassLevel();
        }

        anAug = anAug.next;
    }

    return -1;
}


// ----------------------------------------------------------------------
// CalcEnergyUse()
//
// Calculates energy use for all active augmentations, modified for automatic power recirc
// ----------------------------------------------------------------------

simulated function Float CalcEnergyUse(float deltaTime)
{
    local float f, energyUse, boostedEnergyUse, energyMult, boostMult;
    local Augmentation anAug;

    if(Level.LevelAction != LEVACT_None) return 0;
    deltaTime = FMin(deltaTime, 0.255);// this is usually approximately 0.25

    boostedEnergyUse = 0;
    energyUse = 0;
    energyMult = 1.0;
    boostMult = 1.0;

    Player.AmbientSound = None;

    anAug = FirstAug;
    while(anAug != None)
    {
        if (AugPower(anAug) != None && anAug.bHasIt && anAug.bIsActive)
            energyMult = anAug.GetAugLevelValue();
        if (AugHeartLung(anAug) != None && anAug.bHasIt && anAug.bIsActive)
            boostMult = anAug.GetAugLevelValue();

        if (anAug.bHasIt && anAug.bIsActive)
        {
            f = ((anAug.GetEnergyRate()/60) * deltaTime);
            if(anAug.bBoosted) {
                boostedEnergyUse += f;
            } else {
                energyUse += f;
            }

            if ((anAug.bAutomatic == false && anAug.bAlwaysActive == false) || f > 0.0) {
                Player.AmbientSound = anAug.LoopSound;
            }
        }
        anAug = anAug.next;
    }

    // check for synthetic heart
    energyUse += boostedEnergyUse * boostMult;

    // check for the power augmentation
    energyUse *= energyMult;

    return energyUse;
}

function BoostAugs(bool bBoostEnabled, Augmentation augBoosting)
{
    local Augmentation anAug;

    for(anAug = FirstAug; anAug != None; anAug = anAug.next)
    {
        // Don't boost the augmentation causing the boosting!
        if (anAug == augBoosting) continue;
        anAug.BoostAug(bBoostEnabled);
    }
}
