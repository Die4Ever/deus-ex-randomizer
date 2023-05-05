//=============================================================================
// NSFClone1.
//=============================================================================
class NSFClone1 extends #var(prefix)Terrorist;
// buff MinHealth, nerf GroundSpeed
defaultproperties
{
    MinHealth=0
    GroundSpeed=170
    Fatness=130

    CarcassType=Class'DeusEx.NSFClone1Carcass'
    Texture=Texture'DeusExItems.Skins.PinkMaskTex'
    Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit'
    MultiSkins(0)=Texture'DeusExCharacters.Skins.TerroristTex0'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.SoldierTex2'
    MultiSkins(2)=Texture'DeusExCharacters.Skins.TerroristTex1'
    MultiSkins(3)=Texture'DeusExCharacters.Skins.FordSchickTex0'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.GogglesTex1'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
}
