class DXRMenuUIChoiceEnum extends MenuUIChoiceEnum config(DXRandoOptions) abstract;

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

function PopulateOptions();

function SetInitialOption()
{
    SetValue(0);
}

defaultproperties
{
    defaultInfoWidth=243
    defaultInfoPosX=203
    HelpText=""
    actionText=""
}
