//=============================================================================
// MenuChoice_RevMusic
//=============================================================================

class MenuChoice_RevMusic extends DXRMenuUIChoiceEnum;

var DXRMusic m;
var int num_enabled;
var int total;

// only need to override GetGameSongs in subclasses, and default actionText
function GetGameSongs(out string songs[100])
{
    m.GetRevSongs(songs);
}

function DXRMusic GetDXRMusic()
{
    if(m != None) return m;
    foreach player.AllActors(class'DXRMusic', m) {
        return m;
    }
    return None;
}

function SetValue(int newValue)
{
    Super.SetValue(newValue);
    _SaveSetting();
}

function SetNumEnabledText()
{
    local string text;
    //text = enumText[GetValue()];
    text = num_enabled $ "/" $ total $ " Songs Enabled";
    btnInfo.SetButtonText(text);
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

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
    log(self$" LoadSetting");
    SetInitialOption();
}

// ----------------------------------------------------------------------
// ResetToDefault
// ----------------------------------------------------------------------

function ResetToDefault()
{
    log(self$" ResetToDefault");
    SetValue(0);
    _SaveSetting();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
    HelpText=""
    actionText="Revision Music"
    enumText(0)="Disabled"
    enumText(1)="Enabled"
}
