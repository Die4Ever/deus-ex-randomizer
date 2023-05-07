//=============================================================================
// MenuChoice_PasswordAutofill
//=============================================================================

class MenuChoice_PasswordAutofill extends MenuUIChoiceEnum;

var config int codes_mode;

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

    enumText[0] = "No Assistance";
    enumText[1] = "Mark Known Passwords";
    enumText[2] = "Autofill Passwords";
}

// ----------------------------------------------------------------------
// SetInitialCycleType()
// ----------------------------------------------------------------------

function SetInitialOption()
{
    SetValue(codes_mode);
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
    codes_mode = GetValue();
    //Not actually a style change, but a reasonable way to tell FrobDisplayWindow to update its flag info...
    ChangeStyle();
    SaveConfig();
}

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
    SetValue(codes_mode);
}

// ----------------------------------------------------------------------
// ResetToDefault
// ----------------------------------------------------------------------

function ResetToDefault()
{
    codes_mode = default.codes_mode;
    SetValue(codes_mode);
    SaveSetting();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     codes_mode=2;
     defaultInfoWidth=243
     defaultInfoPosX=203
     HelpText="Help with finding randomized passwords from your notes."
     actionText="Password Assistance"
}
