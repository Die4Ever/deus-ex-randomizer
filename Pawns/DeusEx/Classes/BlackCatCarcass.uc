class BlackCatCarcass extends #var(prefix)CatCarcass;


static function ConvertNormalCat(#var(prefix)CatCarcass cat)
{
    cat.MultiSkins[0]=class'BlackCatCarcass'.Default.MultiSkins[0];
    cat.Fatness=class'BlackCatCarcass'.Default.Fatness;
    cat.ScaleGlow=class'BlackCatCarcass'.Default.ScaleGlow; //To help their eyes shine in dark areas
    cat.bUnlit=class'BlackCatCarcass'.Default.bUnlit;
}

defaultproperties
{
    Fatness=132
    MultiSkins(0)=Texture'BlackCatTex1'
    ScaleGlow=100
    bUnlit=True
}
