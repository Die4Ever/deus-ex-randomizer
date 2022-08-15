//=============================================================================
// MenuChoice_PasswordAutofill
//=============================================================================

class MenuChoice_PasswordAutofill extends MenuUIChoiceEnum;

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

    //enumText[0] = "TO DO"; //Remove once actually implemented
}

// ----------------------------------------------------------------------
// SetInitialCycleType()
// ----------------------------------------------------------------------

function SetInitialOption()
{

    SetValue(player.FlagBase.GetInt('Rando_codes_mode'));
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
    player.FlagBase.SetInt('Rando_codes_mode',GetValue(),,999);

    //Not actually a style change, but a reasonable way to tell FrobDisplayWindow to update its flag info...
    ChangeStyle();
}

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
    SetValue(player.FlagBase.GetInt('Rando_codes_mode'));
}

// ----------------------------------------------------------------------
// ResetToDefault
// ----------------------------------------------------------------------

function ResetToDefault()
{
    SetValue(2);
    SaveSetting();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     defaultInfoWidth=243
     defaultInfoPosX=203
     HelpText="Help with finding passwords from your notes"
     actionText="Password Assistance"
}
