//=============================================================================
// MenuChoice_PasswordAutofill
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
    SaveSetting();
}

function SetEnabledText()
{
    local string text;
    text = enumText[GetValue()];
    text = text $ " (" $ num_enabled $ "/" $ total $ ")";
    // TODO: need a timer like MenuChoice_DisableSong
    //btnInfo.SetButtonText(text); // wonky with the song "Ending" being in both Unreal and UT
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
        SetEnabledText();
    }
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
    local string songs[100];
    local bool bEnabled;

    bEnabled = bool(GetValue());
    log(self$" SaveSetting "$bEnabled);
    if(GetDXRMusic() != None) {
        GetGameSongs(songs);
        m.SetEnabledGameSongs(songs, bEnabled);
        m.SaveConfig();
        if(bEnabled)
            num_enabled = total;
        else
            num_enabled = 0;
        SetEnabledText();
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
    SaveSetting();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
#ifdef injections
    HelpText="Ensure the UMX files are in the right place. You can also edit DXRMusic.ini for further customization."
#else
    HelpText="Ensure the UMX files are in the right place. You can also edit #var(package)Music.ini for further customization."
#endif
    actionText="Unreal Tournament Music"
    enumText(0)="Disabled"
    enumText(1)="Enabled"
}
