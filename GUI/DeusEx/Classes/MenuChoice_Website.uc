//=============================================================================
// MenuChoice_Website
//=============================================================================

class MenuChoice_Website extends MenuUIChoiceAction;

var string url;

// ----------------------------------------------------------------------
// ButtonActivated()
//
// Open the page
// ----------------------------------------------------------------------
function bool ButtonActivated( Window buttonPressed )
{
    player.ConsoleCommand("start "$url);
    return True;
}

event InitWindow()
{
    Super.InitWindow();
    SetActionButtonWidth(350);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     Action=MA_Custom
     HelpText="Open the Mods4Ever.com Website"
     actionText="Go to Mods4Ever.com website"
     url="https://mods4ever.com"
}
