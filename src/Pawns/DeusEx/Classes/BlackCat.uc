class BlackCat extends #var(prefix)Cat;

function bool Facelift(bool bOn)
{
    return false;
}

static function ConvertNormalCat(#var(prefix)Cat cat)
{
    if (cat.CarcassType==class'BlackCat'.Default.CarcassType) return; //This is already a black cat

    cat.MultiSkins[0]=class'BlackCat'.Default.MultiSkins[0];
    cat.Mesh=class'BlackCat'.Default.Mesh; //Black Cats always use the vanilla mesh
    cat.CarcassType=class'BlackCat'.Default.CarcassType;
    cat.Fatness=class'BlackCat'.Default.Fatness;
    cat.ScaleGlow=class'BlackCat'.Default.ScaleGlow; //To help their eyes shine in dark areas
    cat.bUnlit=class'BlackCat'.Default.bUnlit;
}

defaultproperties
{
    CarcassType=class'BlackCatCarcass'
    Fatness=132
    MultiSkins(0)=Texture'BlackCatTex1'
    ScaleGlow=1
    bUnlit=True
}
