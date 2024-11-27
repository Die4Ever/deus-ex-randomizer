//=============================================================================
// MenuChoice_RevPS2Music
//=============================================================================

class MenuChoice_RevPS2Music extends MenuChoice_RevMusic;

// only need to override GetGameSongs in subclasses, and default actionText
function GetGameSongs(out string songs[100])
{
    m.GetRevPS2Songs(songs);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
    HelpText=""
    actionText="PS2 Music"
    enumText(0)="Disabled"
    enumText(1)="Enabled"
}
