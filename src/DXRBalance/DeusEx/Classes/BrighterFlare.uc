class BrighterFlare injects Flare;

// copy states for compatibility with old save files
// override ZoneChange functions so flares don't get extinguished when entering a water zone
auto state Pickup
{
    function ZoneChange(ZoneInfo NewZone)
    {
        Super(DeusExPickup).ZoneChange(NewZone);
    }
}

state Activated
{
    function ZoneChange(ZoneInfo NewZone)
    {
        Super(DeusExPickup).ZoneChange(NewZone);
    }

Begin:
}

defaultproperties
{
    CollisionRadius=6.200000
    CollisionHeight=4
    LightEffect=LE_TorchWaver
    LightBrightness=255
    LightHue=16
    LightSaturation=96
    LightRadius=25
}
