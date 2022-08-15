//=============================================================================
// MenuChoice_EnergyDisplay
//=============================================================================

class MenuChoice_EnergyDisplay extends MenuChoice_VisibleHidden;

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
    SetValue(Int(player.FlagBase.GetBool('DXREnergyMeterHidden')));
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
    player.FlagBase.SetBool('DXREnergyMeterHidden',Bool(GetValue()),,999);

    ChangeStyle();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function ResetToDefault()
{
    SetValue(0);
    SaveSetting();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     defaultInfoWidth=243
     defaultInfoPosX=203
     HelpText="Toggles energy consumption visibility."
     actionText="Energy Consumption"
}
