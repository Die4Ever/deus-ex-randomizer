class DXRToilet2 injects #var(prefix)Toilet2;

var bool bAlreadyUsed;

function Frob(actor Frobber, Inventory frobWith)
{
	local #var(PlayerPawn) player;

	Super.Frob(Frobber, frobWith);

	player = #var(PlayerPawn)(Frobber);
	if (player != None && player.bOnFire)
	{
		player.ClientMessage("Splish Splash!",, true);
		player.ExtinguishFire();

        if (SkinColor==SC_Clean){
            class'DXREvents'.static.ExtinguishFire("clean urinal",player);
        } else {
            class'DXREvents'.static.ExtinguishFire("filthy urinal",player);
        }
    }
    if (player!=None){
        if (!bAlreadyUsed){
            bAlreadyUsed = true;
            class'DXREvents'.static.MarkBingo("FlushUrinal");
        }
    }
}

defaultproperties
{
}
