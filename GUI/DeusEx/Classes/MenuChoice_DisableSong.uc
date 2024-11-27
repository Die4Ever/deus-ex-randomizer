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
    local string song;
    local bool useOgg;

    if(!GetModules()) return true;

#ifdef revision
    useOgg = class'RevJCDentonMale'.Default.bUseRevisionSoundtrack;
#endif

    song = musicplayer.GetCurrentSongName();
    music.SetEnabledSong(song, false);
    if (useOgg){
        #ifdef revision
        musicplayer.PlayRandomOggSong(true);
        #endif
    } else {
        musicplayer.PlayRandomSong(true);
    }
    UpdateText(0,0,0);
    return True;
}

event InitWindow()
{
    Super.InitWindow();
    SetActionButtonWidth(350);

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
#ifdef injections
    HelpText="Disable the current song. You can re-enable it by editing DXRMusic.ini"
#else
    HelpText="Disable the current song. You can re-enable it by editing #var(package)Music.ini"
#endif
     actionText="Disable Song"
}
