//=============================================================================
// MenuChoice_RandomMusic
//=============================================================================

class MenuChoice_FixGlitches extends MenuUIChoiceEnum;

var config bool fix_glitches;

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
    local int typeIndex;

    enumText[0] = "Not Fixed";
    enumText[1] = "Fixed";
}

// ----------------------------------------------------------------------
// SetInitialCycleType()
// ----------------------------------------------------------------------

function SetInitialOption()
{
    SetValue(int(fix_glitches));
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
    fix_glitches = bool(GetValue());
    SaveConfig();
}

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
    SetValue(int(fix_glitches));
}

// ----------------------------------------------------------------------
// ResetToDefault
// ----------------------------------------------------------------------

function ResetToDefault()
{
    fix_glitches = default.fix_glitches;
    SetValue(int(fix_glitches));
    SaveSetting();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     fix_glitches=True;
     defaultInfoWidth=243
     defaultInfoPosX=203
     HelpText="Fix glitches used for speedruns."
     actionText="Glitches For Speedruns"
}
