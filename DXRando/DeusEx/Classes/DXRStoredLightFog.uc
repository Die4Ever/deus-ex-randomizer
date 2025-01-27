class DXRStoredLightFog extends Info;

var int VersionNum; //To theoretically help with upgrades if more information is added in this class

var byte VolumeBrightness;
var byte VolumeFog;
var byte VolumeRadius;


static function DXRStoredLightFog Init(Light l)
{
    local int i;
    local DXRStoredLightFog slf;

    //Only store information for lights that generate fog
    if (l.VolumeFog==0 && l.VolumeRadius==0) return None;

    slf = l.Spawn(class'DXRStoredLightFog',,,l.Location);

    slf.SetOwner(l);

    slf.VolumeBrightness = l.VolumeBrightness;
    slf.VolumeFog = l.VolumeFog;
    slf.VolumeRadius = l.VolumeRadius;

    return slf;
}

defaultproperties
{
    VersionNum=1
    bAlwaysRelevant=True
}
