//=============================================================================
// UNATCOClone4.
//=============================================================================
class UNATCOClone4 extends #var(prefix)UNATCOTroop;
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

    CarcassType=Class'DeusEx.UNATCOClone4Carcass'
    Texture=Texture'DeusExItems.Skins.PinkMaskTex'
    Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit'
    MultiSkins(0)=Texture'DeusExCharacters.Skins.MiscTex1'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.SoldierTex2'
    MultiSkins(2)=Texture'DeusExCharacters.Skins.UNATCOTroopTex2'
    MultiSkins(3)=Texture'DeusExCharacters.Skins.FordSchickTex0'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.UNATCOTroopTex3'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
    FamiliarName="UNATCO Troop 4"
    UnfamiliarName="UNATCO Troop 4"
}
