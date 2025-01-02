class DXRBioelectricCell injects BioelectricCell;

state Activated
{
	function BeginState()
	{
		local DeusExPlayer player;
        local int energy;

		Super(DeusExPickup).BeginState();

		player = DeusExPlayer(Owner);
		if (player != None)
		{
            energy = player.Energy;
			player.Energy += rechargeAmount;
			if (player.Energy > player.EnergyMax)
				player.Energy = player.EnergyMax;
            energy = player.Energy - energy;

			player.ClientMessage(Sprintf(msgRecharged, energy));

			player.PlaySound(sound'BioElectricHiss', SLOT_None,,, 256);
		}

		UseOnce();
	}
Begin:
}
