class DXRMenuUIHelpButtonWindow extends MenuUIActionButtonWindow;

var string HelpTitle,HelpText;

function SetHelpTitle(string title)
{
    HelpTitle = title;
}

function string GetHelpTitle()
{
    return HelpTitle;
}

function SetHelpText(string help)
{
    HelpText = help;
}

function string GetHelpText()
{
    return HelpText;
}
