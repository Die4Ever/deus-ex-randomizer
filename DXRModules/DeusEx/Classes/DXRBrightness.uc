class DXRBrightness expands DXRActorsBase;

struct ZoneBrightnessData
{
    var name zonename;
    var byte brightness, saturation, hue;
};
var ZoneBrightnessData zone_brightness[32];

function int GetSavedBrightnessBoost()
{
    return class'MenuChoice_BrightnessBoost'.default.BrightnessBoost;
}

function PreFirstEntry()
{
    local ZoneInfo Z;

    Super.PreFirstEntry();

    //Save default brightnesses
    SaveDefaultZoneBrightness(Level);
    foreach AllActors(class'ZoneInfo',Z){
        if(SkyZoneInfo(Z) != None) continue;
        SaveDefaultZoneBrightness(Z);
    }
}

function AnyEntry()
{
    Super.AnyEntry();
    IncreaseBrightness(GetSavedBrightnessBoost());
}

function IncreaseBrightness(int brightness)
{
    local ZoneInfo z;

    if (dxr.localURL == "ENDGAME4" || dxr.localURL == "ENDGAME4REV"){
        return;  //Dance Parties don't need to be bright
    }

    IncreaseZoneBrightness(brightness, Level);
    foreach AllActors(class'ZoneInfo', z) {
        if( z == Level ) continue;
        if(SkyZoneInfo(z) != None) continue;
        IncreaseZoneBrightness(brightness, z);
    }
    player().ConsoleCommand("FLUSH"); //Clears the texture cache, which allows the lighting to rerender
}

function IncreaseZoneBrightness(int brightness, ZoneInfo z)
{
    local ZoneBrightnessData zb;
    local float sat_boost;

    zb = GetDefaultZoneBrightness(z);
    z.AmbientBrightness = Clamp( int(zb.brightness) + brightness, 0, 255 );

    // the AmbientSaturation variable is backwards for some reason
    // increase AmbientSaturation, aka decrease the color as the brightness goes up
    sat_boost = float(brightness) / 2;
    z.AmbientSaturation = Clamp( int(zb.saturation) + sat_boost, 0, 255);

    // if the zone had 0 brightness then the color wouldn't have shown, so whatever color it has we need to disable it
    if(zb.brightness == 0)
        z.AmbientSaturation = 255;
}

static function AdjustBrightness(DeusExPlayer a, int brightness)
{
    local DXRBrightness b;

    foreach a.AllActors(class'DXRBrightness',b){
        b.IncreaseBrightness(brightness);
    }
}

function ZoneBrightnessData GetDefaultZoneBrightness(ZoneInfo z)
{
    local ZoneBrightnessData zb;
    local int i;
    for(i=0; i<ArrayCount(zone_brightness); i++) {
        if( z.name == zone_brightness[i].zonename )
            return zone_brightness[i];
    }
    return zb;
}

function SaveDefaultZoneBrightness(ZoneInfo z)
{
    local int i;
    for(i=0; i<ArrayCount(zone_brightness); i++) {
        if( zone_brightness[i].zonename == '' || z.name == zone_brightness[i].zonename ) {
            zone_brightness[i].zonename = z.name;
            zone_brightness[i].brightness = z.AmbientBrightness;
            zone_brightness[i].saturation = z.AmbientSaturation;
            zone_brightness[i].hue = z.AmbientHue;
            return;
        }
    }
}
