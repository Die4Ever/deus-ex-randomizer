//=============================================================================
// UNATCOCloneAugStealth1Carcass.
//=============================================================================
class UNATCOCloneAugStealth1Carcass extends UNATCOClone2Carcass;

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
    MultiSkins(0)=Texture'UNATCOCloneAugStealth1HeadNoglow'
    MultiSkins(1)=Texture'UNATCOCloneAugStealth1Legs'
    MultiSkins(2)=Texture'UNATCOCloneAugStealth1Body'
    MultiSkins(3)=Texture'UNATCOCloneAugStealth1Head'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(6)=Texture'UNATCOCloneAugStealth1Helmet'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
}
