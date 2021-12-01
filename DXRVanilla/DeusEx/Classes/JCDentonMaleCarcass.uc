class DXRJCDentonMaleCarcass injects JCDentonMaleCarcass;

function SetSkin(DeusExPlayer player)
{
    local int i;

    if( player == None ) {
        Super.SetSkin(player);
        return;
    }

    //FASHION!
    switch(player.Mesh) {
        case LodMesh'DeusExCharacters.GFM_Trench':
            Mesh = LodMesh'DeusExCharacters.GFM_Trench_Carcass';
            Mesh2 = LodMesh'DeusExCharacters.GFM_Trench_CarcassB';
            Mesh3 = LodMesh'DeusExCharacters.GFM_Trench_CarcassC';
            break;
        
        case LodMesh'DeusExCharacters.GFM_SuitSkirt':
        case LodMesh'DeusExCharacters.GFM_SuitSkirt_F':
            Mesh = LodMesh'DeusExCharacters.GFM_SuitSkirt_Carcass';
            Mesh2 = LodMesh'DeusExCharacters.GFM_SuitSkirt_CarcassB';
            Mesh3 = LodMesh'DeusExCharacters.GFM_SuitSkirt_CarcassC';
            break;
        
        case LodMesh'DeusExCharacters.GFM_TShirtPants':
            Mesh = LodMesh'DeusExCharacters.GFM_TShirtPants_Carcass';
            Mesh2 = LodMesh'DeusExCharacters.GFM_TShirtPants_CarcassB';
            Mesh3 = LodMesh'DeusExCharacters.GFM_TShirtPants_CarcassC';
            break;

        case LodMesh'DeusExCharacters.GM_Trench_F':
        case LodMesh'DeusExCharacters.GM_Trench':
            Mesh = LodMesh'DeusExCharacters.GM_Trench_Carcass';
            Mesh2 = LodMesh'DeusExCharacters.GM_Trench_CarcassB';
            Mesh3 = LodMesh'DeusExCharacters.GM_Trench_CarcassC';
            break;
            
        case LodMesh'MPCharacters.mp_jumpsuit':
        case LodMesh'DeusExCharacters.GM_DressShirt_B':
        case LodMesh'DeusExCharacters.GM_DressShirt':
        case LodMesh'DeusExCharacters.GM_DressShirt_F':
        case LodMesh'DeusExCharacters.GM_DressShirt_S':
        case LodMesh'DeusExCharacters.GM_Jumpsuit':
        case LodMesh'DeusExCharacters.GMK_DressShirt':
        case LodMesh'DeusExCharacters.GMK_DressShirt_F':
        case LodMesh'DeusExCharacters.GM_Suit':
            Mesh = LodMesh'DeusExCharacters.GM_Jumpsuit_Carcass';
            Mesh2 = LodMesh'DeusExCharacters.GM_Jumpsuit_CarcassB';
            Mesh3 = LodMesh'DeusExCharacters.GM_Jumpsuit_CarcassC';
            self.Texture = player.Texture;
            break;
    }
    
    for (i = 0; i <= 7; i++) {
        MultiSkins[i]=player.MultiSkins[i];
    }

}
