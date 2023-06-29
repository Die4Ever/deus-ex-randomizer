//=============================================================================
// MJ12CloneAugStealth1NametagCarcass.
//=============================================================================
class MJ12CloneAugStealth1NametagCarcass extends MJ12Clone2Carcass;

function InitFor(Actor Other)
{
    Super.InitFor(Other);
    MultiSkins[6] = default.MultiSkins[6];
}

defaultproperties
{
    Mesh2=LodMesh'DeusExCharacters.GM_Jumpsuit_CarcassB'
    Mesh3=LodMesh'DeusExCharacters.GM_Jumpsuit_CarcassC'
    Texture=Texture'DeusExItems.Skins.PinkMaskTex'
    Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit_Carcass'
    MultiSkins(0)=Texture'Textures\MJ12CloneAugStealth1HeadNoglow.pcx'
    MultiSkins(1)=Texture'Textures\MJ12CloneAugStealth1Legs.pcx'
    MultiSkins(2)=Texture'Textures\MJ12CloneAugStealth1BodyNametag.pcx'
    MultiSkins(3)=Texture'Textures\MJ12CloneAugStealth1HeadNoglow.pcx' //this is where you need the face texture
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'Textures\MJ12CloneAugStealth1GogglesDark.pcx'
    MultiSkins(6)=Texture'Textures\MJ12CloneAugStealth1Goggles.pcx'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
}
