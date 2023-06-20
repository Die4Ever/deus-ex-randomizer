//=============================================================================
// MenuChoice_MirrorMaps
//=============================================================================

class MenuChoice_MirrorMaps extends MenuUIChoiceSlider config(DXRandoOptions);

var config int mirror_maps;

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
    saveValue = mirror_maps;
    SetValue(saveValue);
}

// ----------------------------------------------------------------------
// CancelSetting()
// ----------------------------------------------------------------------

function CancelSetting()
{
    mirror_maps = saveValue;
    SaveConfig();
}

// ----------------------------------------------------------------------
// ResetToDefault()
// ----------------------------------------------------------------------

function ResetToDefault()
{
    mirror_maps = int(defaultValue);
    SetValue(mirror_maps);
    SaveConfig();
}

function SetEnumerators()
{
    local int i;
    local bool maps_files_found;

    maps_files_found = class'DXRMapVariants'.static.MirrorMapsAvailable();

    if(maps_files_found) {
        HelpText = default.HelpText;
        actionText = default.actionText;
        numTicks = default.numTicks;
        btnAction.SetButtonText(actionText);
    }
    else {
        mirror_maps = 0;
        endValue = 0;
        numTicks = 1;
        SetValue(mirror_maps);
        SaveSetting();
        btnAction.SetWidth(243);
        HelpText = "Use the installer to download the mirrored map files, or go to the unreal-map-flipper Releases page on Github";
        actionText = "Mirror Map Files Not Found";
        btnAction.SetButtonText(actionText);
        SetEnumeration(0, "Missing");
        btnSlider.Hide();
        btnSlider.SetTicks(numTicks, startValue, endValue);
        return;
    }

    for (i=0;i<numTicks;i++){
        SetEnumeration(i, string(i)$"%");
    }
}

// ----------------------------------------------------------------------
// ScalePositionChanged() : Called when an ancestor scale window's
//                          position is moved
// ----------------------------------------------------------------------

event bool ScalePositionChanged(Window scale, int newTickPosition,
                                float newValue, bool bFinal)
{
    // Don't do anything while initializing as we get several
    // ScalePositionChanged() events before LoadSetting() is called.

    if (bInitializing)
        return False;

    mirror_maps = int(GetValue());

    if(bFinal){
        SaveConfig();
    }

    return false;
}

function CreateActionButton()
{
    Super.CreateActionButton();
    SetActionButtonWidth(179);
}

function float GetValue()
{
    return int(Super.GetValue());
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
    numTicks=101
    startValue=0
    endValue=100
    defaultValue=0
    mirror_maps=0
    choiceControlPosX=203
    actionText="Mirror Maps (Beta)"
    HelpText="Enable mirrored maps if you have the files downloaded for them."
}
