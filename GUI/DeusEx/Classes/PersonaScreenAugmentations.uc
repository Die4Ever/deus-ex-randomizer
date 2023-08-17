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
