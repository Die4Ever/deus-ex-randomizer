//=============================================================================
// MenuChoice_ReleasePage
//=============================================================================

class MenuChoice_ReleasePage extends MenuUIChoiceAction;

var string release_url;

// ----------------------------------------------------------------------
// ButtonActivated()
//
// Open the releases page
// ----------------------------------------------------------------------
function bool ButtonActivated( Window buttonPressed )
{
    player.ConsoleCommand("start "$release_url);
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
     HelpText="Open the Deus Ex Randomizer latest release webpage on GitHub"
     actionText="Download Latest Deus Ex Randomizer"
     release_url="https://github.com/Die4Ever/deus-ex-randomizer/releases/latest"
}
