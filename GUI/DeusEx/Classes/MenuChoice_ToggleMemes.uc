class MenuChoice_ToggleMemes extends MenuUIChoiceAction;

var DXRando dxr;

function bool GetDXR()
{
    if(dxr == None)
        foreach player.AllActors(class'DXRando', dxr) { break; }
    return dxr != None;
}

function EnableMemes()
{
    local int i;

    if(!GetDXR()) return;

    for(i=0; i<ArrayCount(dxr.modules_to_load); i++) {
        if(dxr.modules_to_load[i] == "") {
            dxr.modules_to_load[i] = "DXRMemes";
            dxr.SaveConfig();
            return;
        }
    }
}

function DisableMemes()
{
    local int i;

    if(!GetDXR()) return;

    for(i=0; i<ArrayCount(dxr.modules_to_load); i++) {
        if(dxr.modules_to_load[i] ~= "DXRMemes") {
            dxr.modules_to_load[i] = "";
            dxr.SaveConfig();
            return;
        }
    }
}

function bool ButtonActivated( Window buttonPressed )
{
    local string t;

    t = btnAction.buttonText;
    if(t == default.actionText) {
        DisableMemes();
    } else {
        EnableMemes();
    }
    UpdateButtonText();

    return true;
}

event InitWindow()
{
    Super.InitWindow();
    SetActionButtonWidth(260);
    UpdateButtonText();
}

function UpdateButtonText()
{
    local bool enabled;
    local int i;

    if(!GetDXR()) return;

    for(i=0; i<ArrayCount(dxr.modules_to_load); i++) {
        if(dxr.modules_to_load[i] ~= "DXRMemes") {
            enabled = true;
            break;
        }
    }

    if(enabled)
        btnAction.SetButtonText(default.actionText);
    else
        btnAction.SetButtonText("Enable Memes");
}

function ResetToDefault()
{
    EnableMemes();
    UpdateButtonText();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
    Action=MA_Custom
    HelpText="Disable cutscene randomization and a few other things. This is automatically disabled for Zero Rando and Rando Lite modes."
    actionText="Disable Memes"
}
