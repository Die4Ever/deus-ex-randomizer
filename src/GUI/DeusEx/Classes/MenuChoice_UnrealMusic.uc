class MenuChoice_UnrealMusic extends MenuChoice_UTMusic;

// only need to override GetGameSongs in subclasses, and default actionText
function GetGameSongs(out string songs[100])
{
    m.GetUnrealSongs(songs);
}

defaultproperties
{
    actionText="Unreal Music"
}
