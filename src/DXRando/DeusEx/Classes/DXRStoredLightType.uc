class DXRStoredLightType extends Info;

var int VersionNum; //To theoretically help with upgrades if more information is added in this class

var ELightType origLightType;


static function DXRStoredLightType Init(Light l)
{
    local int i;
    local DXRStoredLightType slf;

    //Only store information for lights that have problematic light types
    if (!(l.LightType==LT_Flicker || l.LightType==LT_Strobe)) return None;

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
