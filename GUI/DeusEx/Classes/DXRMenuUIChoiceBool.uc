class DXRMenuUIChoiceBool extends MenuUIChoiceEnum config(DXRandoOptions) abstract;

var config bool enabled;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
    Super.InitWindow();

    SetInitialOption();

    SetActionButtonWidth(179);
}

// ----------------------------------------------------------------------
// SetInitialCycleType()
// ----------------------------------------------------------------------

function SetInitialOption()
{
    SetValue(int(enabled));
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
    enabled = bool(GetValue());
    SaveConfig();
}

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
    SetValue(int(enabled));
}

// ----------------------------------------------------------------------
// ResetToDefault
// ----------------------------------------------------------------------

function ResetToDefault()
{
    enabled = default.enabled;
    SetValue(int(enabled));
    SaveSetting();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
    enabled=True;
    defaultInfoWidth=243
    defaultInfoPosX=203
    HelpText=""
    actionText=""
    enumText(0)="Disabled"
    enumText(1)="Enabled"
}
