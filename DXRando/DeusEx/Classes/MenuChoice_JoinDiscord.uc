//=============================================================================
// MenuChoice_JoinDiscord
//=============================================================================

class MenuChoice_JoinDiscord extends MenuUIChoiceAction;

var string discord_url;

// ----------------------------------------------------------------------
// ButtonActivated()
//
// Open the releases page
// ----------------------------------------------------------------------
function bool ButtonActivated( Window buttonPressed )
{
    player.ConsoleCommand("start "$discord_url);
	return True;
}

event InitWindow()
{
	Super.InitWindow();
    SetActionButtonWidth(260);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     Action=MA_Custom
     HelpText="Opens a link to the Deus Ex Randomizer Discord server"
     actionText="Join the Discord server"
     discord_url="https://discord.gg/daQVyAp2ds"
}
