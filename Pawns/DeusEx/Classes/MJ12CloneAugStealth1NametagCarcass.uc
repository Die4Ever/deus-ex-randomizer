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
    MultiSkins(0)=Texture'MJ12CloneAugStealth1HeadNoglow'
    MultiSkins(1)=Texture'MJ12CloneAugStealth1Legs'
    MultiSkins(2)=Texture'MJ12CloneAugStealth1BodyNametag'
    MultiSkins(3)=Texture'MJ12CloneAugStealth1Head'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'MJ12CloneAugStealth1Goggles'
    MultiSkins(6)=Texture'MJ12CloneAugStealth1GogglesDark'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
}
