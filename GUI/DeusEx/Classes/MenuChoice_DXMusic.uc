class MenuChoice_DXMusic extends MenuChoice_UTMusic;

// only need to override GetGameSongs in subclasses, and default actionText
function GetGameSongs(out string songs[100])
{
    m.GetDXSongs(songs);
}

defaultproperties
{
    actionText="Deus Ex Music"
}
