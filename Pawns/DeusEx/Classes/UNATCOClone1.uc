//=============================================================================
// UNATCOClone1.
//=============================================================================
class UNATCOClone1 extends #var(prefix)UNATCOTroop;
// buff GroundSpeed, nerf Health
defaultproperties
{
    Health=80
    HealthHead=80
    HealthTorso=80
    HealthLegLeft=80
    HealthLegRight=80
    HealthArmLeft=80
    HealthArmRight=80
    Fatness=120
    DrawScale=0.95
    CollisionRadius=19
    CollisionHeight=45.125
    GroundSpeed=230

    CarcassType=Class'DeusEx.UNATCOClone1Carcass'
    Texture=Texture'DeusExItems.Skins.PinkMaskTex'
    Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit'
    MultiSkins(0)=Texture'DeusExCharacters.Skins.MiscTex1'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.MJ12TroopTex1'
    MultiSkins(2)=Texture'DeusExCharacters.Skins.UNATCOTroopTex2'
    MultiSkins(3)=Texture'DeusExCharacters.Skins.SkinTex1'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.UNATCOTroopTex3'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
    FamiliarName="UNATCO Troop 1"
    UnfamiliarName="UNATCO Troop 1"
}
