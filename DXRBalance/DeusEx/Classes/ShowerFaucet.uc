class ShowerFaucet injects ShowerFaucet;

function Frob(actor Frobber, Inventory frobWith)
{
	local DeusExPlayer player;

	Super.Frob(Frobber, frobWith);

	player = DeusExPlayer(Frobber);
	if (player != None && player.bOnFire)
	{
		player.ClientMessage("Splish Splash!",, true);
		player.ExtinguishFire();
	}
}

defaultproperties
{
}
