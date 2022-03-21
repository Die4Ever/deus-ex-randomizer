class ShowerFaucet injects ShowerFaucet;

function Frob(actor Frobber, Inventory frobWith)
{
	local DeusExPlayer player;
    local DXRando      dxr;
    local bool         wasOnFire;

	player = DeusExPlayer(Frobber);
    wasOnFire = (player != None && player.bOnFire);

	Super.Frob(Frobber, frobWith);

	if (wasOnFire && !player.bOnFire)
	{
		player.ClientMessage("Splish Splash!",, true);

        foreach AllActors(class'DXRando', dxr) {
            class'DXREvents'.static.ExtinguishFire(dxr,"shower",player);
            break;
        }
	}
}

defaultproperties
{
}
