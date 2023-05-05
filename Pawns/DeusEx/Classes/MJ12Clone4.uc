//=============================================================================
// MJ12Clone4.
//=============================================================================
class MJ12Clone4 extends #var(prefix)MJ12Troop;
// buff Health, nerf BaseAccuracy
defaultproperties
{
    Health=120
    HealthHead=120
    HealthTorso=120
    HealthLegLeft=120
    HealthLegRight=120
    HealthArmLeft=120
    HealthArmRight=120
    BaseAccuracy=0.25
    Fatness=130
    DrawScale=1.05
    CollisionRadius=21
    CollisionHeight=49.875

    CarcassType=Class'DeusEx.MJ12Clone4Carcass'
    Texture=Texture'DeusExItems.Skins.PinkMaskTex'
    Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit'
    MultiSkins(0)=Texture'DeusExCharacters.Skins.SkinTex1'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.PantsTex5'
    MultiSkins(2)=Texture'DeusExCharacters.Skins.MJ12TroopTex2'
    MultiSkins(3)=Texture'DeusExCharacters.Skins.PhilipMeadTex0'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExCharacters.Skins.MJ12TroopTex3'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.MJ12TroopTex4'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
}
