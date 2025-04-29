class DXRBrightness expands DXRActorsBase transient;

//This struct (and it's corresponding array) won't be actively used anymore
//TODO: To be removed in a future release
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
    local Light lght;

    Super.PreFirstEntry();

    //Save default brightnesses
    foreach AllActors(class'ZoneInfo',Z){
        class'DXRStoredZoneInfo'.static.Init(Z);
    }

    //Save information about lights with fog effects
    foreach AllActors(class'Light',lght){
        class'DXRStoredLightFog'.static.Init(lght);
        class'DXRStoredLightType'.static.Init(lght);
    }
}

function AnyEntry()
{
    Super.AnyEntry();

    MigrateSavedData(); //TODO: To be removed when the ZoneBrightnessData is stripped out
    //UpdateStoredData(); //If more is added to DXRStoredZoneInfo or DXRStoredLightFog

    IncreaseBrightness(GetSavedBrightnessBoost());
    ApplyFog(class'MenuChoice_Fog'.default.enabled);
    ApplyEpilepsySafe(class'MenuChoice_Epilepsy'.default.enabled);
}

//TODO: To be removed when the ZoneBrightnessData is stripped out
function MigrateSavedData()
{
    local DXRStoredZoneInfo szi;
    local ZoneInfo z;
    local ZoneBrightnessData zb;
    local Light lght;

    foreach AllActors(class'DXRStoredZoneInfo',szi){break;}
    if (szi!=None) return; //No migration necessary, the information has already been stored

    foreach AllActors(class'ZoneInfo',z){
        zb = GetDefaultZoneBrightness(z);
        szi = class'DXRStoredZoneInfo'.static.Init(z);

        if (szi.bSkyZone) continue; //No changes to sky zones

        //Need to restore the previously saved info
        szi.AmbientBrightness = zb.brightness;
        szi.AmbientSaturation = zb.saturation;
        szi.AmbientHue        = zb.hue;
        IncreaseZoneBrightnessGeneric(0,szi); //Restore the zone back to defaults
    }

    //Create the light fog info as well
    foreach AllActors(class'Light',lght){
        class'DXRStoredLightFog'.static.Init(lght);
    }

}

function ApplyFog(bool enabled)
{
    local bool fogOn;
    local DXRStoredZoneInfo szi;
    local DXRStoredLightFog slf;
    local ZoneInfo z;
    local Light lght;
    local Byte brightness,fog,radius;

    //I *think* that bFogZone basically determines whether the
    //fog effects on lights actually get rendered or not.
    //Leaving bFogZone on, but disabling the fog on the lights
    //seems to work just as well as the old method of setting bFogZone
    //to false via a "set" command.
    foreach AllActors(class'DXRStoredZoneInfo',szi){
        if (enabled) {
            fogOn = szi.bFogZone;
        } else {
            fogOn = False;
        }
        z = ZoneInfo(szi.Owner);
        if (z==None) continue;

        //This doesn't actually work
        z.SetPropertyText("bFogZone",string(fogOn));
    }

    //I'm pretty sure the lights do all the fogginess
    foreach AllActors(class'DXRStoredLightFog',slf){
        if (enabled) {
            brightness=slf.VolumeBrightness;
            fog=slf.VolumeFog;
            radius=slf.VolumeRadius;
        } else {
            brightness=0;
            fog=0;
            radius=0;
        }
        lght=Light(slf.Owner);
        if (lght==None) continue;

        lght.VolumeBrightness=brightness;
        lght.VolumeFog=fog;
        lght.VolumeRadius=radius;
    }
}

function ApplyEpilepsySafe(bool enabled)
{
    local DXRStoredLightType slt;
    local Light lght;

    foreach AllActors(class'DXRStoredLightType',slt){
        lght = Light(slt.Owner);
        if (lght==None) continue;

        if (enabled){
            lght.LightType = LT_Pulse; //more gentle light mode
        } else {
            lght.LightType = slt.origLightType;
        }
    }
}

function IncreaseBrightness(int brightness)
{
    local ZoneInfo z;
    local DXRStoredZoneInfo szi;

    if (dxr.localURL == "ENDGAME4" || dxr.localURL == "ENDGAME4REV"){
        return;  //Dance Parties don't need to be bright
    }

    foreach AllActors(class'DXRStoredZoneInfo',szi){
        IncreaseZoneBrightnessGeneric(brightness,szi);
    }

    player().ConsoleCommand("FLUSH"); //Clears the texture cache, which allows the lighting to rerender
}

function IncreaseZoneBrightnessGeneric(int brightness, DXRStoredZoneInfo szi)
{
    local ZoneInfo z;

    if (szi.bSkyZone) return;

    if (szi.bLevelInfo){
        z = Level;
    } else {
        z = ZoneInfo(szi.Owner);
    }

    IncreaseZoneBrightness(brightness,z,szi);
}

function IncreaseZoneBrightness(int brightness, ZoneInfo z, DXRStoredZoneInfo szi)
{
    local float sat_boost;

    z.AmbientBrightness = Clamp( int(szi.AmbientBrightness) + brightness, 0, 255 );

    // the AmbientSaturation variable is backwards for some reason
    // increase AmbientSaturation, aka decrease the color as the brightness goes up
    sat_boost = float(brightness) / 2;
    z.AmbientSaturation = Clamp( int(szi.AmbientSaturation) + sat_boost, 0, 255);

    // if the zone had 0 brightness then the color wouldn't have shown, so whatever color it has we need to disable it
    if(szi.AmbientBrightness == 0)
        z.AmbientSaturation = 255;

    if(dxr.flags.IsHalloweenMode()) {
        z.AmbientBrightness = Max(z.AmbientBrightness, 5);
        z.AmbientSaturation = Min(z.AmbientSaturation, 100);
        z.AmbientHue = 255;
    }
}

static function AdjustBrightness(DeusExPlayer a, int brightness)
{
    local DXRBrightness b;

    foreach a.AllActors(class'DXRBrightness',b){
        b.IncreaseBrightness(brightness);
    }
}

//TODO: To be removed when the ZoneBrightnessData is stripped out
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

//DO NOT USE - TODO: To be removed when the ZoneBrightnessData is stripped out
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
