class DXRPaulDentonCarcass injects PaulDentonCarcass;

function SetSkin(DeusExPlayer player)
{
	local int i;
    
    Super.SetSkin(player);


    //FASHION!
    if (player.Mesh == LodMesh'DeusExCharacters.GM_Trench') {
        Mesh = LodMesh'DeusExCharacters.GM_Trench_Carcass';
        Mesh2 = LodMesh'DeusExCharacters.GM_Trench_CarcassB';
        Mesh3 = LodMesh'DeusExCharacters.GM_Trench_CarcassC';
    } else {
        Mesh = LodMesh'DeusExCharacters.GM_DressShirt_Carcass';
        Mesh2 = LodMesh'DeusExCharacters.GM_DressShirt_CarcassB';
        Mesh3 = LodMesh'DeusExCharacters.GM_DressShirt_CarcassC';
    }
    for (i = 1; i <= 5; i++) { //Paul doesn't get the sunglasses
        MultiSkins[i]=player.MultiSkins[i];
    }

            
}