class DXRPaulDentonCarcass injects PaulDentonCarcass;

function SetSkin(DeusExPlayer player)
{
    local int i;

    Super.SetSkin(player);

    if( player == None ) {
        return;
    }
    //FASHION!
    if (player.Mesh == LodMesh'DeusExCharacters.GM_Trench') {
        Mesh = LodMesh'DeusExCharacters.GM_Trench_Carcass';
        Mesh2 = LodMesh'DeusExCharacters.GM_Trench_CarcassB';
        Mesh3 = LodMesh'DeusExCharacters.GM_Trench_CarcassC';
        for (i = 1; i <= 5; i++) { //Paul doesn't get the sunglasses
            MultiSkins[i]=player.MultiSkins[i];
        }
    } else {
        Mesh = LodMesh'DeusExCharacters.GM_Jumpsuit_Carcass';
        Mesh2 = LodMesh'DeusExCharacters.GM_Jumpsuit_CarcassB';
        Mesh3 = LodMesh'DeusExCharacters.GM_Jumpsuit_CarcassC';
        for (i = 1; i <= 7; i++) { //Paul doesn't get the sunglasses
            MultiSkins[i]=player.MultiSkins[i];
        }
        MultiSkins[3] = MultiSkins[0]; //This is another face texture

        self.Texture = player.Texture;
    }

}

// Make paul's lifeless body even more mortal so it can be picked up for the "PaulToTong" goal.
// It could be made bInvincible again after calling Super.Frob, but keeping the corpse intact after finding it is
// probably a fair, and minor, challenge.
function Frob(Actor frobber, Inventory frobWith)
{
    bInvincible = false;
    Super.Frob(frobber, frobWith);
}
