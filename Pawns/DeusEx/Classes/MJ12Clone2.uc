//=============================================================================
// MJ12Clone2.
//=============================================================================
class MJ12Clone2 extends #var(prefix)MJ12Troop;
// buff BaseAccuracy, nerf Health
defaultproperties
{
    Health=80
    HealthHead=80
    HealthTorso=80
    HealthLegLeft=80
    HealthLegRight=80
    HealthArmLeft=80
    HealthArmRight=80
    BaseAccuracy=0.17
    Fatness=120
    DrawScale=0.95
    CollisionRadius=19
    CollisionHeight=45.125

    CarcassType=Class'DeusEx.MJ12Clone2Carcass'
    Texture=Texture'DeusExItems.Skins.PinkMaskTex'
    Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit'
    MultiSkins(0)=Texture'DeusExCharacters.Skins.SkinTex1'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.PantsTex8'
    MultiSkins(2)=Texture'DeusExCharacters.Skins.MJ12TroopTex2'
    MultiSkins(3)=Texture'DeusExCharacters.Skins.FordSchickTex0'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExCharacters.Skins.MJ12TroopTex3'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.MJ12TroopTex4'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
    FamiliarName="MJ12 Troop 2"
    UnfamiliarName="MJ12 Troop 2"
}
