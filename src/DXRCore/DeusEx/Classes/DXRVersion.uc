class DXRVersion extends Info;

//#region version info
simulated static function CurrentVersion(optional out int major, optional out int minor, optional out int patch, optional out int build)
{
    major=3;
    minor=7;
    patch=0;
    build=1;//build can't be higher than 99
}

simulated static function bool VersionIsStable()
{
    return false;
}

simulated static function string VersionString(optional bool full)
{
    local int major,minor,patch,build;
    local string status;

    status = "Beta";

//#endregion
//////
////// you probably don't need to touch anything below here
//////
//#region utility functions
    if(status!="") {
        status = " " $ status;
        full = true;
    }
    CurrentVersion(major,minor,patch,build);
    return VersionToString(major, minor, patch, build, full) $ status;
}

simulated static function int VersionToInt(int major, int minor, int patch, int build)
{
    return major*1000000+minor*10000+patch*100+build;
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

simulated static function bool FeatureFlag(int major, int minor, int patch, string feature) // make sure to have an issue in GitHub with the feature flag name! and it should be attached to a milestone
{
    if(#bool(allfeatures)) return true;
    #ifdef enablefeature
        if("#var(enablefeature)" == feature) return true;
    #endif

    if(VersionNumber() >= VersionToInt(major, minor, patch, 0)) {
        log("WARNING: FeatureFlag " $ feature $ " only requires v" $ major $ "." $ minor $ "." $ patch, default.class.name);
        return true;
    }
    return false;
}

simulated static function bool VersionOlderThan(int config_version, int major, int minor, int patch, int build)
{
    return config_version < VersionToInt(major, minor, patch, build);
}
//#endregion
