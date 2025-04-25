//=============================================================================
// VialPoo.
//=============================================================================
class VialPoo extends DeusExPickup;

var localized String msgEffect;

state Activated
{
	function Activate()
	{
		// can't turn it off
	}

	function BeginState()
	{
		local DeusExPlayer player;

		Super.BeginState();

		player = DeusExPlayer(Owner);
		if (player != None)
			player.ClientMessage(msgEffect);

		UseOnce();
	}
Begin:
}

defaultproperties
{
     msgEffect="yum yum in my tum tum"
     maxCopies=10
     bCanHaveMultipleCopies=True
     bActivatable=True
     ItemName="Fecal Transplant"
     ItemArticle="a"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.VialAmbrosia'
     PickupViewMesh=LodMesh'DeusExItems.VialAmbrosia'
     ThirdPersonMesh=LodMesh'DeusExItems.VialAmbrosia'
     LandSound=Sound'DeusExSounds.Generic.GlassHit1'
     Icon=Texture'DeusExUI.Icons.BeltIconVialAmbrosia'
     largeIcon=Texture'DeusExUI.Icons.LargeIconVialAmbrosia'
     largeIconWidth=18
     largeIconHeight=44
     Description="Yum!  A turd transporter!"
     beltDescription="POO"
     Mesh=LodMesh'DeusExItems.VialAmbrosia'
     CollisionRadius=2.200000
     CollisionHeight=4.890000
     Mass=2.000000
     Buoyancy=3.000000
     MultiSkins(1)=Texture'DeusExDeco.Skins.AlarmLightTex9'
}
