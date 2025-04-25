class DynamicLight extends Light;

var byte OtherBrightness;
var byte OtherHue;

function BaseChange()
{
    Super.BaseChange();
    if(Base==None) Destroy();
}

function Trigger(actor Other, pawn EventInstigator)
{
    local byte b;

    b = LightBrightness;
    LightBrightness = OtherBrightness;
    OtherBrightness = b;

    b = LightHue;
    LightHue = OtherHue;
    OtherHue = b;
}

defaultproperties
{
    bStatic=false
    bNoDelete=false
    bMovable=true
}
