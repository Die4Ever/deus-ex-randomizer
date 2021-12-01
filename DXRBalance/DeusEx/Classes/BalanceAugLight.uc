class BalanceAugLight injects AugLight;

function SetBeamLocation()
{
    Super.SetBeamLocation();
    if( b1 == None || b2 == None )
        return;
    
    b1.LightRadius *= 2;
    b1.LightBrightness = 220; // default is 192
    b2.LightRadius = 8; // default is 4
    // white like a new high tech LED flashlight? little bit of blue like JC's eyes?
    b1.LightHue = 172;
    b2.LightHue = 172;
    b1.LightSaturation = 140; // default is 140
    b2.LightSaturation = 140; // default is 140
}

defaultproperties
{
    EnergyRate=0.000000
    LevelValues(0)=1000
}
