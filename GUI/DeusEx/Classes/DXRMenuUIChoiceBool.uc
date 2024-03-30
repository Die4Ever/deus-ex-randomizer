class DXRMenuUIChoiceBool extends DXRMenuUIChoiceEnum abstract;

var config bool enabled;
var bool defaultvalue;

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
    enabled = defaultvalue;
    SetValue(int(enabled));
    SaveSetting();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
    enabled=True
    defaultvalue=True
    enumText(0)="Disabled"
    enumText(1)="Enabled"
}
