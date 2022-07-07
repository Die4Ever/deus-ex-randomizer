class DXRShowerFaucet injects #var(prefix)ShowerFaucet;

function Frob(actor Frobber, Inventory frobWith)
{
	local #var(PlayerPawn) player;
    local DXRando      dxr;
    local bool         wasOnFire;

	player = #var(PlayerPawn)(Frobber);
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
