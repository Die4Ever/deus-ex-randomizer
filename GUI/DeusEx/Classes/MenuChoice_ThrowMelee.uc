//=============================================================================
// MenuChoice_RandomMusic
//=============================================================================

class MenuChoice_ThrowMelee extends MenuUIChoiceEnum;

var config bool throw_melee;

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

    enumText[0] = "Don't Throw";
    enumText[1] = "Throw";
}

// ----------------------------------------------------------------------
// SetInitialCycleType()
// ----------------------------------------------------------------------

function SetInitialOption()
{
    SetValue(int(throw_melee));
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
    throw_melee = bool(GetValue());
    SaveConfig();
}

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
    SetValue(int(throw_melee));
}

// ----------------------------------------------------------------------
// ResetToDefault
// ----------------------------------------------------------------------

function ResetToDefault()
{
    throw_melee = default.throw_melee;
    SetValue(int(throw_melee));
    SaveSetting();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     throw_melee=True;
     defaultInfoWidth=243
     defaultInfoPosX=203
     HelpText="How to handle melee weapons when enemies die."
     actionText="Melee Weapons"
}
