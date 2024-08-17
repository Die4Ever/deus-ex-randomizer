class BlackCat extends #var(prefix)Cat;

static function ConvertNormalCat(#var(prefix)Cat cat)
{
    if (cat.CarcassType==class'BlackCat'.Default.CarcassType) return; //This is already a black cat

    cat.MultiSkins[0]=class'BlackCat'.Default.MultiSkins[0];
    cat.CarcassType=class'BlackCat'.Default.CarcassType;
    cat.Fatness=class'BlackCat'.Default.Fatness;
    cat.ScaleGlow=class'BlackCat'.Default.ScaleGlow; //To help their eyes shine in dark areas
}

defaultproperties
{
    CarcassType=class'BlackCatCarcass'
    Fatness=132
    MultiSkins(0)=Texture'BlackCatTex1'
    ScaleGlow=100
}
