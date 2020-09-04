//=============================================================================
// DXRToiletWater.
//=============================================================================
class DXRToiletWater expands Triggers;

function Trigger(Actor Other, Pawn Instigator)
{
	local DeusExPlayer player;

	Super.Trigger(Other, Instigator);

	player = DeusExPlayer(Instigator);

	if (player != None)
	{
		player.ClientMessage("Splish Splash!");
		if (player.bOnFire)
		    player.ExtinguishFire();
	}
}

defaultproperties
{
}
