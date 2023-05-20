//=============================================================================
// MenuChoice_ContinuousMusic
//=============================================================================

class MenuChoice_ContinuousMusic extends MenuUIChoiceEnum config(DXRandoOptions);

var config int continuous_music;
var int disabled;
var int simple;
var int advanced;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
    Super.InitWindow();

    PopulateOptions();

    SetInitialOption();

    SetActionButtonWidth(179);
}

// ----------------------------------------------------------------------
// PopulateCycleTypes()
// ----------------------------------------------------------------------

function PopulateOptions()
{
    enumText[disabled] = "Normal Music";
    enumText[simple] = "Continuous Music (Simple)";
    enumText[advanced] = "Continuous Music";
}

// ----------------------------------------------------------------------
// SetInitialCycleType()
// ----------------------------------------------------------------------

function SetInitialOption()
{
    SetValue(continuous_music);
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
    continuous_music = GetValue();
    //Not actually a style change, but a reasonable way to tell FrobDisplayWindow to update its flag info...
    //ChangeStyle();
    SaveConfig();
}

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
    SetValue(continuous_music);
}

// ----------------------------------------------------------------------
// ResetToDefault
// ----------------------------------------------------------------------

function ResetToDefault()
{
    continuous_music = default.continuous_music;
    SetValue(continuous_music);
    SaveSetting();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
    continuous_music=2
    disabled=0
    simple=1
    advanced=2
    defaultInfoWidth=243
    defaultInfoPosX=203
    HelpText="Continue music through loading screens."
    actionText="Continuous Music"
}
