//=============================================================================
// MenuChoice_UTMusic
//=============================================================================

class MenuChoice_UTMusic extends DXRMenuUIChoiceEnum;

var DXRMusic m;
var int num_enabled;
var int total;

// only need to override GetGameSongs in subclasses, and default actionText
function GetGameSongs(out string songs[100])
{
    m.GetUTSongs(songs);
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
    bEnabled = m.AreGameSongsEnabled(songs, num_enabled, total);
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
        bEnabled = m.AreGameSongsEnabled(songs, num_enabled, total);
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
        m.SetEnabledGameSongs(songs, bEnabled);
        m.SaveConfig();
        bEnabled = m.AreGameSongsEnabled(songs, num_enabled, total);
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
#ifdef injections
    HelpText="BRING YOUR OWN FILES. Ensure the UMX files are in the right place.|nYou can also edit DXRMusic.ini for further customization."
#else
    HelpText="BRING YOUR OWN FILES. Ensure the UMX files are in the right place.|nYou can also edit #var(package)Music.ini for further customization."
#endif
    actionText="Unreal Tournament Music"
    enumText(0)="Disabled"
    enumText(1)="Enabled"
}
