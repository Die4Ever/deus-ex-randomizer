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
