class BlackCatCarcass extends #var(prefix)CatCarcass;

function bool Facelift(bool bOn)
{
    return false;
}

#ifdef gmdxae
//GMDX:AE functions to do HDTP and Augmentique skin randomization
exec function UpdateHDTPsettings(){}
function SetupSkin(){}
#endif

static function ConvertNormalCat(#var(prefix)CatCarcass cat)
{
    cat.MultiSkins[0]=class'BlackCatCarcass'.Default.MultiSkins[0];
    cat.Mesh=class'BlackCatCarcass'.Default.Mesh; //Black Cats always use the vanilla mesh
    cat.Fatness=class'BlackCatCarcass'.Default.Fatness;
    cat.ScaleGlow=class'BlackCatCarcass'.Default.ScaleGlow; //To help their eyes shine in dark areas
    cat.bUnlit=class'BlackCatCarcass'.Default.bUnlit;
}

defaultproperties
{
    Fatness=132
    MultiSkins(0)=Texture'BlackCatTex1'
    ScaleGlow=1
    bUnlit=True
    Mesh=LodMesh'DeusExCharacters.CatCarcass'
    Mesh2=LodMesh'DeusExCharacters.CatCarcass'
    Mesh3=LodMesh'DeusExCharacters.CatCarcass'
}
