//=============================================================================
// MenuChoice_JoinDiscord
//=============================================================================

class MenuChoice_OpenUrl extends MenuUIChoiceAction abstract;

var string open_url;

// ----------------------------------------------------------------------
// ButtonActivated()
//
// Open the releases page
// ----------------------------------------------------------------------
function bool ButtonActivated( Window buttonPressed )
{
    class'DXRInfo'.static.OpenURL(player, open_url);
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
    HelpText="Search for Deus Ex Randomizer"
    actionText="Search for Deus Ex Randomizer"
    open_url="https://letmegooglethat.com/?q=Deus+Ex+Randomizer"
}
