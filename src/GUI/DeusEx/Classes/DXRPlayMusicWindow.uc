class DXRPlayMusicWindow injects PlayMusicWindow;

var ToolRadioButtonWindow	btnCustomSection;
var ToolEditWindow          customSectionWin;
var DXRMusic                m;

function CreateControls()
{
    //This needs to be initialized after InitWindow, but before PopulateSongsList
    foreach player.AllActors(class'DXRMusic',m){break;}

    super.CreateControls();

    radSongType.SetSize(100, 150);

    btnCustomSection = ToolRadioButtonWindow(winSongType.NewChild(Class'ToolRadioButtonWindow'));
    btnCustomSection.SetText("C|&ustom");
    btnCustomSection.SetPos(0, 120);

    customSectionWin = CreateToolEditWindow(290, 205, 50, 3);
    customSectionWin.SetFilter(" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz~`!@#$%^&*()=+\|[{]};:,<.>/?'" $ Chr(34)); //Stolen from FlagAddWindow
    customSectionWin.SetText("0");
}

function EnableButtons()
{
    local bool enable;
    local string songChoice;
    local int selected;

    enable = true;

    //Something has to actually be selected
    if (lstSongs.GetNumSelectedRows() == 0) enable = false;

    //The file for that selected song has to actually exist
    selected = lstSongs.GetSelectedRow();
    songChoice = lstSongs.GetField(selected,1); //First column is the human name, second is the actual song file name
    if (m!=None && !m.bSongExists(songChoice)) enable = false;

	btnPlay.SetSensitivity( enable );
}


function PopulateSongsList()
{
    local int i;
    local string songChoice;

    //foreach player.AllActors(class'DXRMusic',m){break;}

    if (m==None){
        //Just populate it normally if we don't have DXRMusic
        Super.PopulateSongsList();
        return;
    }

    for (i=0;i<m.GetChoiceListLength();i++){
        m.GetChoiceAtIndex(i,songChoice);
        if (songChoice=="") continue;

        //if (!m.bSongExists(songChoice)) continue;

        lstSongs.AddRow(songChoice$";"$songChoice);
    }

    // Sort the maps by name
    lstSongs.Sort();

    EnableButtons();


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
    else if (btnCustomSection.GetToggle())
        songSection = Int(customSectionWin.GetText()); //Pull section from entry box

    songName = lstSongs.GetField(rowID, 1);

#ifdef vanilla
    Human(player).PlayExactMusic(songName, songSection);
#else
    player.PlayMusic(songName, songSection);
#endif
}
