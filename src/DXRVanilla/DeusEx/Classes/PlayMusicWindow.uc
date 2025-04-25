class PlayMusicWindow injects PlayMusicWindow;

var ToolRadioButtonWindow btnAmbient2;

function CreateControls()
{
    Super.CreateControls();

    btnAmbient2 = ToolRadioButtonWindow(winSongType.NewChild(Class'ToolRadioButtonWindow'));
    btnAmbient2.SetText("|&Ambient 2");
    btnAmbient2.SetPos(0, 100);
}

function PlaySong(int rowID)
{
    local String songName;
    local Int songSection;

//   0 - Ambient 1
//   1 - Dying
//   2 - Ambient 2 (optional)
//   3 - Combat
//   4 - Conversation
//   5 - Outro

    if (btnAmbient.GetToggle())
        songSection = 0;
    else if (btnCombat.GetToggle())
        songSection = 3;
    else if (btnConversation.GetToggle())
        songSection = 4;
    else if (btnOutro.GetToggle())
        songSection = 5;
    else if (btnDying.GetToggle())
        songSection = 1;
    else if (btnAmbient2.GetToggle())
        songSection = 2;

    songName = lstSongs.GetField(rowID, 1);
    player.PlayMusic(songName, songSection);
}
