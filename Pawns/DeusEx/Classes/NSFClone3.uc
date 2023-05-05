//=============================================================================
// NSFClone3.
//=============================================================================
class NSFClone3 extends #var(prefix)Terrorist;
// buff MinHealth, nerf Health
defaultproperties
{
    MinHealth=0
    Health=60
    HealthHead=60
    HealthTorso=60
    HealthLegLeft=60
    HealthLegRight=60
    HealthArmLeft=60
    HealthArmRight=60
    Fatness=115
    DrawScale=0.9
    CollisionRadius=18
    CollisionHeight=42.75

    CarcassType=Class'DeusEx.NSFClone3Carcass'
    Texture=Texture'DeusExItems.Skins.PinkMaskTex'
    Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit'
    MultiSkins(0)=Texture'DeusExCharacters.Skins.TerroristTex0'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.PantsTex3'
    MultiSkins(2)=Texture'DeusExCharacters.Skins.TerroristTex1'
    MultiSkins(3)=Texture'DeusExCharacters.Skins.TriadRedArrowTex0'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.GogglesTex1'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
}
