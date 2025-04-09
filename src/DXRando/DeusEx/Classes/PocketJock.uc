class PocketJock extends DeusExPickup;

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
		{
		    //Do Pocket Jock things here
            //

            player.PlaySound(Sound'PocketJockLetsGo', SLOT_Misc,5.0,, 500);
		}

		UseOnce();
	}
Begin:
}

defaultproperties
{
     PickupViewScale=0.2
     ThirdPersonScale=0.2
     PlayerViewScale=0.2
     bCanHaveMultipleCopies=False
     bActivatable=True
     ItemName="Pocket Jock"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExCharacters.GM_Trench'
     PickupViewMesh=LodMesh'DeusExCharacters.GM_Trench'
     ThirdPersonMesh=LodMesh'DeusExCharacters.GM_Trench'
     Icon=Texture'InfoPortraits.Jock'
     largeIcon=Texture'InfoPortraits.Jock'
     largeIconWidth=42
     largeIconHeight=43
     Description="It's a Jock that fits in your pocket.  He can show you the world!"
     beltDescription="P JOCK"
     Mesh=LodMesh'DeusExCharacters.GM_Trench'
     CollisionRadius=4.000
     CollisionHeight=9.5
     Mass=2.000000
     Buoyancy=10.000000
     MultiSkins(0)=Texture'DeusExCharacters.Skins.JockTex0'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.JockTex2'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.JockTex3'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.JockTex0'
     MultiSkins(4)=Texture'DeusExCharacters.Skins.JockTex1'
     MultiSkins(5)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(6)=Texture'DeusExCharacters.Skins.FramesTex2'
     MultiSkins(7)=Texture'DeusExCharacters.Skins.LensesTex3'
}
