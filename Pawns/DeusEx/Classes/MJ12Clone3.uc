//=============================================================================
// MJ12Clone3.
//=============================================================================
class MJ12Clone3 extends DXRMJ12TroopBase;
// buff MinHealth, nerf Health
defaultproperties
{
    MinHealth=0
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

    CarcassType=Class'DeusEx.MJ12Clone3Carcass'
    Texture=Texture'DeusExItems.Skins.PinkMaskTex'
    Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit'
    MultiSkins(0)=Texture'DeusExCharacters.Skins.SkinTex1'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.RiotCopTex1'
    MultiSkins(2)=Texture'DeusExCharacters.Skins.MJ12TroopTex2'
    MultiSkins(3)=Texture'DeusExCharacters.Skins.TriadRedArrowTex0'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExCharacters.Skins.MJ12TroopTex3'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.MJ12TroopTex4'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
    FamiliarName="MJ12 Troop 3"
    UnfamiliarName="MJ12 Troop 3"
}
