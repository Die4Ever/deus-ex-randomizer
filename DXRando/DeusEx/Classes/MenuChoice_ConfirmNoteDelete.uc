//=============================================================================
// MenuChoice_ConfirmNoteDelete
//=============================================================================

class MenuChoice_ConfirmNoteDelete extends MenuUIChoiceEnum;

var config bool confirm_delete;

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

    enumText[0] = "Don't Confirm";
    enumText[1] = "Confirm";
}

// ----------------------------------------------------------------------
// SetInitialCycleType()
// ----------------------------------------------------------------------

function SetInitialOption()
{
    SetValue(int(confirm_delete));
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
    confirm_delete = bool(GetValue());
    //Not actually a style change, but a reasonable way to tell FrobDisplayWindow to update its flag info...
    ChangeStyle();
    SaveConfig();
}

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
    SetValue(int(confirm_delete));
}

// ----------------------------------------------------------------------
// ResetToDefault
// ----------------------------------------------------------------------

function ResetToDefault()
{
    confirm_delete = default.confirm_delete;
    SetValue(int(confirm_delete));
    SaveSetting();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     confirm_delete=True;
     defaultInfoWidth=243
     defaultInfoPosX=203
     HelpText="Confirm when deleting a note"
     actionText="Confirm Note Deletion"
}
