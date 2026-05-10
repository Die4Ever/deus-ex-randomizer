class DXRStoredLightType extends Info;

var int VersionNum; //To theoretically help with upgrades if more information is added in this class

var ELightType origLightType;


static function DXRStoredLightType Init(Light l)
{
    local DXRStoredLightType slf;

    //Only store information for lights that have problematic light types
    //GMDX and Revision use LT_Blink in a few places, which seems basically the same as Flicker and Strobe
    if (!(l.LightType==LT_Flicker || l.LightType==LT_Strobe || l.LightType==LT_Blink)) return None;

    slf = l.Spawn(class'DXRStoredLightType',,,l.Location);

    slf.SetOwner(l);

    slf.origLightType = l.LightType;

    return slf;
}

defaultproperties
{
    VersionNum=1
    bAlwaysRelevant=True
}
