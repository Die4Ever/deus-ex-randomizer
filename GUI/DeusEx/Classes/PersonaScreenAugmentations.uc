//Already "merges"d in Lay D Denton, so merging here as well
class DXRPersonaScreenAugmentations merges PersonaScreenAugmentations;

function CreateBioCellBar()
{
    _CreateBioCellBar();

    //Vanilla location seems to be too close to the bottom of the bar.  Bumped up one pixel
    winBioEnergyText.SetPos(446, 390);
}

function UpdateBioEnergyBar()
{
	local float energyPercent;

    if (player==None){
        log("Player doesn't exist while updating BioEnergyBar - probably dead?");
        return;
    }

	energyPercent = 100.0 * (player.Energy / player.EnergyMax);

	winBioEnergy.SetCurrentValue(energyPercent);
	winBioEnergyText.SetText(Int(player.Energy)$"/"$Int(player.EnergyMax)$" Energy");
}

//Same as vanilla but also checks if the player is targeting a can
function UpdateAugCans()
{
    local Inventory anItem;
    local int augCanCount;

    if (winAugCans != None)
    {
        winAugCans.SetText(AugCanUseText);

        // Loop through the player's inventory and count how many upgrade cans
        // the player has
        anItem = player.Inventory;

        while(anItem != None)
        {
            if (anItem.IsA('#var(prefix)AugmentationUpgradeCannister'))
                augCanCount++;

            anItem = anItem.Inventory;
        }

        //This part is new
        if (#var(prefix)AugmentationUpgradeCannister(player.FrobTarget)!=None){
            augCanCount++;
        }

        winAugCans.SetCount(augCanCount);
    }
}

function UpgradeAugmentation()
{
    local AugmentationUpgradeCannister augCan;
    local bool wasFrobTarget;
    local int levelBefore;
    local DXRando dxr;

    if (selectedAug!=None){
        levelBefore = selectedAug.CurrentLevel;
    }


    //This indented section was vanilla (except for the part about FrobTarget)

        // First make sure we have a selected Augmentation
        if (selectedAug == None)
            return;

        if (#var(prefix)AugmentationUpgradeCannister(player.FrobTarget)!=None){
            augCan = #var(prefix)AugmentationUpgradeCannister(player.FrobTarget);
            player.AddInventory(augCan); //Needs to be in inventory so the Aug can see it is available for upgrading
            wasFrobTarget=True;
        } else {
            // Now check to see if we have an upgrade cannister
            augCan = #var(prefix)AugmentationUpgradeCannister(player.FindInventoryType(Class'#var(prefix)AugmentationUpgradeCannister'));
        }

        if (augCan != None)
        {
            // Increment the level and remove the aug cannister from
            // the player's inventory

            selectedAug.IncLevel();
            selectedAug.UpdateInfo(winInfo);

            augCan.UseOnce();
            if (wasFrobTarget){
                player.FrobTarget=None;
            }

            // Update the level icons
            if (selectedAugButton != None)
                PersonaAugmentationItemButton(selectedAugButton).SetLevel(selectedAug.GetCurrentLevel());
        }

        UpdateAugCans();
        EnableButtons();

    //End of vanilla aug menu logic

    if (selectedAug!=None){
        if (selectedAug.CurrentLevel!=levelBefore){
            foreach player.AllActors(class'DXRando',dxr){break;}
            class'DXREvents'.static.MarkBingo(dxr,"AugUpgraded"); //General "Upgrade x augs" kind of situation
            class'DXREvents'.static.MarkBingo(dxr,selectedAug.Class.Name$"Upgraded"); //aug-specific upgrade goals
            class'DXREvents'.static.MarkBingo(dxr,"AugLevel"$(selectedAug.CurrentLevel+1)); //"Get X Augs to level Y" type goals

        }
    }
}

function EnableButtons()
{
    _EnableButtons();

    // vanilla disables the aug enable/disable button when you have 0 energy, but automatic augs make that incorrect

    // if we have a selected aug then we need to check to enable the button
    if (selectedAug != None) {
        // if it's always active then you can never enable/disable it anyways
        if(!selectedAug.IsAlwaysActive()) {
            // if it's active then enable the button because you should always be able to disable an aug
            // if it's automatic then you should always be able to enable/disable the aug
            if(selectedAug.bIsActive || selectedAug.bAutomatic) {
                btnActivate.EnableWindow(true);
            }
        }

        //Allow upgrading with a highlighted aug upgrade
        if (#var(prefix)AugmentationUpgradeCannister(player.FrobTarget)!=None){
            btnUpgrade.EnableWindow(selectedAug.currentLevel < selectedAug.MaxLevel);
        }

    }
}

function RedrawAugmentations()
{
    local int i;

    selectedAug=None;
    selectedAugButton=None;

    for (i=0;i<ArrayCount(augItems);i++){
        if (augItems[i]!=None){
            augItems[i].Destroy();
            augItems[i]=None;
        }
    }
    CreateAugmentationButtons();
}
