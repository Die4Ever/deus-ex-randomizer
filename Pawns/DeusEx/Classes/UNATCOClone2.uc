//=============================================================================
// UNATCOClone2.
//=============================================================================
class UNATCOClone2 extends #var(prefix)UNATCOTroop;
// buff GroundSpeed, nerf BaseAccuracy
defaultproperties
{
    GroundSpeed=230
    BaseAccuracy=0.25
    Fatness=120

    CarcassType=Class'DeusEx.UNATCOClone2Carcass'
    Texture=Texture'DeusExItems.Skins.PinkMaskTex'
    Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit'
    MultiSkins(0)=Texture'DeusExCharacters.Skins.MiscTex1'
    MultiSkins(1)=Texture'DeusExCharacters.Skins.UNATCOTroopTex1'
    MultiSkins(2)=Texture'DeusExCharacters.Skins.UNATCOTroopTex2'
    MultiSkins(3)=Texture'DeusExCharacters.Skins.BartenderTex0'
    MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
    MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
    MultiSkins(6)=Texture'DeusExCharacters.Skins.UNATCOTroopTex3'
    MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
    FamiliarName="UNATCO Troop 2"
    UnfamiliarName="UNATCO Troop 2"
}
