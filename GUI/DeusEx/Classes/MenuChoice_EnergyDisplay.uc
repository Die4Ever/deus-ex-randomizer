//=============================================================================
// MenuChoice_EnergyDisplay
//=============================================================================

class MenuChoice_EnergyDisplay extends MenuChoice_VisibleHidden config(DXRandoOptions);

var config bool bEnergyDisplayHidden;

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------
event InitWindow()
{
    Super.InitWindow();
    SetActionButtonWidth(179);
}

function LoadSetting()
{
    SetValue(Int(bEnergyDisplayHidden));
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
    local HUDEnergyDisplay hud;
    bEnergyDisplayHidden = bool(GetValue());
    SaveConfig();
    ChangeStyle();
    foreach AllObjects(class'HUDEnergyDisplay', hud) {
        hud.StyleChanged();
    }
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function ResetToDefault()
{
    SetValue(0);
    bEnergyDisplayHidden = false;
    SaveSetting();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
    bEnergyDisplayHidden=false
    defaultInfoWidth=243
    defaultInfoPosX=203
    HelpText="Toggles energy consumption visibility."
    actionText="Energy Consumption"
}
