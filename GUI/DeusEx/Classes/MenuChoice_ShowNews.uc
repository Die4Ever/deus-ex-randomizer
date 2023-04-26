//=============================================================================
// MenuChoice_ShowNews
//=============================================================================

class MenuChoice_ShowNews extends MenuUIChoiceEnum;

var config bool show_news;

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

    enumText[0] = "News Hidden";
    enumText[1] = "News Shown";
}

// ----------------------------------------------------------------------
// SetInitialCycleType()
// ----------------------------------------------------------------------

function SetInitialOption()
{
    SetValue(int(show_news));
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
    show_news = bool(GetValue());
    SaveConfig();
}

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
    SetValue(int(show_news));
}

// ----------------------------------------------------------------------
// ResetToDefault
// ----------------------------------------------------------------------

function ResetToDefault()
{
    show_news = default.show_news;
    SetValue(int(show_news));
    SaveSetting();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
    show_news=true
    defaultInfoWidth=243
    defaultInfoPosX=203
    HelpText="Show or hide the news on the main menu. Reopen the main menu to take effect."
    actionText="News on the main menu"
}
