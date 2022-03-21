class Toilet2 injects Toilet2;

function Frob(actor Frobber, Inventory frobWith)
{
	local DeusExPlayer player;
    local DXRando      dxr;

	Super.Frob(Frobber, frobWith);

	player = DeusExPlayer(Frobber);
	if (player != None && player.bOnFire)
	{
		player.ClientMessage("Splish Splash!",, true);
		player.ExtinguishFire();

        foreach AllActors(class'DXRando', dxr) {
            if (SkinColor==SC_Clean){
                class'DXREvents'.static.ExtinguishFire(dxr,"clean urinal",player);
            } else {
                class'DXREvents'.static.ExtinguishFire(dxr,"filthy urinal",player);
            }
            break;
        }
    }
}

defaultproperties
{
}
