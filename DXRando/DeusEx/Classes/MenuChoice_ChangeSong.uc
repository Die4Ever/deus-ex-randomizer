//=============================================================================
// MenuChoice_ChangeSong
//=============================================================================

class MenuChoice_ChangeSong extends MenuUIChoiceAction;

// ----------------------------------------------------------------------
// ButtonActivated()
//
// Change the song
// ----------------------------------------------------------------------
function bool ButtonActivated( Window buttonPressed )
{
    local DXRMusic music;
    foreach player.AllActors(class'DXRMusic', music) {
        music.PlayRandomSong(false);
    }
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
     HelpText="Change the song if you have Randomizer Music enabled"
     actionText="Change Song"
}
