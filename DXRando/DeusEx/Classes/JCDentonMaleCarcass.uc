class DXRJCDentonMaleCarcass injects JCDentonMaleCarcass;

function SetSkin(DeusExPlayer player)
{
	Super.SetSkin(player);

        //FASHION!
        MultiSkins[1]=player.MultiSkins[1];
	MultiSkins[5]=player.MultiSkins[5];
	MultiSkins[4]=player.MultiSkins[4];
	MultiSkins[2]=player.MultiSkins[2];         
}