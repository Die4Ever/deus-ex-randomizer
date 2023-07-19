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
