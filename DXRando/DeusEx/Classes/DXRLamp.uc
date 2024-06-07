class DXRLamp injects #var(prefix)Lamp;

// should always be called when first entering a map
function InitLight()
{
    LightHue = Default.LightHue;
    LightSaturation = Default.LightSaturation;
    LightBrightness = Default.LightBrightness;
    LightRadius = Default.LightRadius;

    SetState(bOn);
}

function SetState(bool turnOn)
{
    if (turnOn) {
        bOn = True;
        LightType = LT_Steady;
        bUnlit = True;
        ScaleGlow = 2.5;
    } else if (bOn) {
        bOn = False;
        LightType = LT_None;
        bUnlit = False;
        ResetScaleGlow();
    }
}
