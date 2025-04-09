//=============================================================================
// MenuChoice_RevMusic
//=============================================================================

class MenuChoice_RevMusic extends MenuChoice_UTMusic;

// only need to override GetGameSongs in subclasses, and default actionText
function GetGameSongs(out string songs[100])
{
    m.GetRevSongs(songs);
}

function UpdateTextTimer(int timerID, int invocations, int clientData)
{
    local string songs[100];
    local bool bEnabled;

    GetGameSongs(songs);
    bEnabled = m.AreOggGameSongsEnabled(songs, num_enabled, total);
    SetNumEnabledText();
}

// ----------------------------------------------------------------------
// SetInitialCycleType()
// ----------------------------------------------------------------------

function SetInitialOption()
{
    local string songs[100];
    local bool bEnabled;

    if(GetDXRMusic() != None) {
        GetGameSongs(songs);
        bEnabled = m.AreOggGameSongsEnabled(songs, num_enabled, total);
        log(self$" SetInitialOption "$bEnabled);
        Super.SetValue(int(bEnabled));
        SetNumEnabledText();
        AddTimer(0.5, true, 0, 'UpdateTextTimer');
    }
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function _SaveSetting()
{
    local string songs[100];
    local bool bEnabled;

    bEnabled = bool(GetValue());
    log(self$" SaveSetting "$bEnabled);
    if(GetDXRMusic() != None) {
        GetGameSongs(songs);
        m.SetEnabledOggGameSongs(songs, bEnabled);
        m.SaveConfig();
        bEnabled = m.AreOggGameSongsEnabled(songs, num_enabled, total);
        SetNumEnabledText();
    }
}

defaultproperties
{
    HelpText=""
    actionText="Revision Music"
    enumText(0)="Disabled"
    enumText(1)="Enabled"
}
