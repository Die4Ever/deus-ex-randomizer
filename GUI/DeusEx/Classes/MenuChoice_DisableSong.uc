class MenuChoice_DisableSong extends MenuUIChoiceAction;

var DXRMusic music;
var DXRMusicPlayer musicplayer;

function bool GetModules()
{
    if(music == None)
        foreach player.AllActors(class'DXRMusic', music) { break; }
    if(musicplayer == None)
        foreach player.AllActors(class'DXRMusicPlayer', musicplayer) { break; }

    if(music == None || musicplayer == None)
        return false;
    return true;
}

function bool ButtonActivated( Window buttonPressed )
{
    local DXRMusic music;
    local DXRMusicPlayer musicplayer;
    local string song;

    if(!GetModules()) return true;

    song = musicplayer.GetCurrentSongName();
    music.SetEnabledSong(song, false);
    musicplayer.PlayRandomSong(true);
    UpdateText(0,0,0);
    return True;
}

event InitWindow()
{
    Super.InitWindow();
    SetActionButtonWidth(446);

    AddTimer(0.5, true, 0, 'UpdateText');
    UpdateText(0,0,0);
}

function UpdateText(int timerID, int invocations, int clientData)
{
    local string song;

    if(!GetModules()) return;

    song = musicplayer.GetCurrentSongName();
    btnAction.SetButtonText(default.actionText @ song);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     Action=MA_Custom
     HelpText="Disable the current song. You can renable it by editing DXRMusic.ini"
     actionText="Disable Song"
}
