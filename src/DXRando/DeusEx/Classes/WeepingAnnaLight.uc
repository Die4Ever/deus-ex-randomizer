class WeepingAnnaLight extends DynamicLight;

function Tick(float delta)
{
    local float brightness, scale;

    Super.Tick(delta);

    scale = 1.0 - Abs(LifeSpan - default.LifeSpan/2) * (2/default.LifeSpan);
    brightness = scale * 250.0;
    LightBrightness = Clamp(brightness, 0, 180);
}

defaultproperties
{
    LifeSpan=0.25
    LightBrightness=0
    LightRadius=3
}
