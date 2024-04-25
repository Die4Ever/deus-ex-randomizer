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
    local DXRMusicPlayer music;
    foreach player.AllActors(class'DXRMusicPlayer', music) {
        music.SkipSong();
    }
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
     HelpText="Change the song if you have Randomizer Music enabled"
     actionText="Change Song"
}
