//=============================================================================
// MJ12Clone1.
//=============================================================================
class MJ12Clone1 extends DXRMJ12TroopBase;
// buff Health, MinHealth, BaseAccuracy
defaultproperties
{
    MinHealth=0
    Health=120
    HealthHead=120
    HealthTorso=120
    HealthLegLeft=120
    HealthLegRight=120
    HealthArmLeft=120
    HealthArmRight=120
    BaseAccuracy=0.17
    Fatness=130
    DrawScale=1.05
    CollisionRadius=21
    CollisionHeight=49.875

    Alliance=mj12
    InitialAlliances(0)=(AllianceName=Player,AllianceLevel=-1,bPermanent=True)

    CarcassType=Class'DeusEx.MJ12Clone1Carcass'
    Texture=Texture'DeusExItems.Skins.PinkMaskTex'
    Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit'
    MultiSkins(0)=Texture'DeusExCharacters.Skins.SkinTex1'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.MJ12TroopTex1'
    MultiSkins(2)=Texture'DeusExCharacters.Skins.MJ12TroopTex2'
    MultiSkins(3)=Texture'DeusExCharacters.Skins.MiscTex1'
    MultiSkins(4)=Texture'DeusExCharacters.Skins.MiscTex1'
    MultiSkins(5)=Texture'DeusExCharacters.Skins.MJ12TroopTex3'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.MJ12TroopTex4'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
    FamiliarName="MJ12 Executioner"
    UnfamiliarName="MJ12 Executioner"
}
