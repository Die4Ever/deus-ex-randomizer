class MenuChoice_MirrorMaps extends DXRMenuUIChoiceEnum;

var config int mirror_maps;
var int disabled;
var int enabled;
var int mirror_only;

// ----------------------------------------------------------------------
// PopulateCycleTypes()
// ----------------------------------------------------------------------

function PopulateOptions()
{
    local bool maps_files_found;

#ifdef injections
    maps_files_found = class'DXRMapVariants'.static.MirrorMapsAvailable();
#endif

    if(maps_files_found) {
        HelpText = default.HelpText;
        enumText[disabled] = "Mirror Maps Disabled";
        enumText[enabled] = "Mirror Maps Enabled";
        enumText[mirror_only] = "Only Use Mirror Maps";
    }
    else {
        mirror_maps = disabled;
        SetValue(mirror_maps);
        SaveSetting();
        HelpText = "Use the installer to download the mirrored map files, or go to the unreal-map-flipper Releases page on Github";
        enumText[disabled] = "Mirror Map Files Not Found";
    }
}

// ----------------------------------------------------------------------
// SetInitialCycleType()
// ----------------------------------------------------------------------

function SetInitialOption()
{
    SetValue(mirror_maps);
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
    mirror_maps = GetValue();
    SaveConfig();
}

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
    SetValue(mirror_maps);
}

// ----------------------------------------------------------------------
// ResetToDefault
// ----------------------------------------------------------------------

function ResetToDefault()
{
    mirror_maps = default.mirror_maps;
    SetValue(mirror_maps);
    SaveSetting();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
    mirror_maps=0
    disabled=0
    enabled=1
    mirror_only=2
    HelpText="Enable mirrored maps if you have the files downloaded for them."
    actionText="Mirror Maps (Alpha)"
}
