//Already "merges"d in Lay D Denton, so merging here as well
class DXRPersonaScreenAugmentations merges PersonaScreenAugmentations;

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

function UpgradeAugmentation()
{
    local int levelBefore;
    local DXRando dxr;

    if (selectedAug!=None){
        levelBefore = selectedAug.CurrentLevel;
    }

    _UpgradeAugmentation();

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
