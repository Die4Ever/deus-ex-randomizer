class DXRVersion extends Info;

simulated static function CurrentVersion(optional out int major, optional out int minor, optional out int patch, optional out int build)
{
    major=2;
    minor=6;
    patch=0;
    build=6;//build can't be higher than 99
}

simulated static function bool VersionIsStable()
{
    return true;
}

simulated static function string VersionString(optional bool full)
{
    local int major,minor,patch,build;
    local string status;

    status = "";

    if(status!="") {
        status = " " $ status;
        full = true;
    }
    CurrentVersion(major,minor,patch,build);
    return VersionToString(major, minor, patch, build, full) $ status;
}

//////
////// you probably don't need to touch the stuff below
//////

simulated static function int VersionToInt(int major, int minor, int patch, int build)
{
    local int ret;
    ret = major*10000+minor*100+patch;
    if( ret <= 10400 ) return minor;//v1.4 and earlier
    if( ret > 10508 ) {
        ret = major*1000000+minor*10000+patch*100+build;
    }
    return ret;
}

simulated static function string VersionToString(int major, int minor, int patch, optional int build, optional bool full)
{
    if( full )
        return "v" $ major $"."$ minor $"."$ patch $"."$ build;
    else if( patch == 0 )
        return "v" $ major $"."$ minor;
    else
        return "v" $ major $"."$ minor $"."$ patch;
}

simulated static function int VersionNumber()
{
    local int major,minor,patch,build;
    CurrentVersion(major,minor,patch,build);
    return VersionToInt(major, minor, patch, build);
}

simulated static function bool VersionOlderThan(int config_version, int major, int minor, int patch, int build)
{
    return config_version < VersionToInt(major, minor, patch, build);
}
