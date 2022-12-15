class DXRPersonaScreenGoals injects PersonaScreenGoals;

var PersonaActionButtonWindow btnBingo, btnGoalHints;
var string goalRandoWikiUrl;
var string InfoWindowHeader, InfoWindowText;

function CreateControls()
{
    local DXRando dxr;

    Super.CreateControls();

    btnBingo = PersonaActionButtonWindow(winClient.NewChild(Class'PersonaActionButtonWindow'));
    btnBingo.SetButtonText("|&Bingo");
    btnBingo.SetPos(545, 1);
    btnBingo.SetSensitivity(true);

    foreach player.AllActors(class'DXRando',dxr){
        if (dxr.flags.settings.goals > 0) {
            btnGoalHints = PersonaActionButtonWindow(winClient.NewChild(Class'PersonaActionButtonWindow'));
            btnGoalHints.SetButtonText("|&Goal Randomization Info");
            btnGoalHints.SetWindowAlignments(HALIGN_Left, VALIGN_Top, 13, 179);
            btnGoalHints.SetSensitivity(true);
        }
        break;
    }
}

event bool BoxOptionSelected(Window msgBoxWindow, int buttonNumber)
{
    local MenuUIMessageBoxWindow msgBox;
    local string action;
    local bool handled;

    msgBox = MenuUIMessageBoxWindow(msgBoxWindow);
    if (msgBox.winText.GetText()==InfoWindowText){
        log("Info window");
        if (buttonNumber==0){
            action="wiki";
        }
        handled=True;
    }

    if (action=="wiki"){
        player.ConsoleCommand("start "$goalRandoWikiUrl);
    }

    if (handled){
        // Destroy the msgbox!
	    root.PopWindow();
        return true;
    }

    return Super.BoxOptionSelected(msgBoxWindow,buttonNumber);
}

function bool ButtonActivated( Window buttonPressed )
{
    if(buttonPressed == btnBingo) {
        SaveSettings();
        root.InvokeUIScreen(class'PersonaScreenBingo');
        return true;
    } else if(buttonPressed == btnGoalHints) {
        SaveSettings();
        root.MessageBox(InfoWindowHeader,InfoWindowText,0,False,Self);
        return true;
    }
    return Super.ButtonActivated(buttonPressed);
}

defaultproperties
{
     InfoWindowHeader="Open Wiki?"
     InfoWindowText="Would you like to open the DXRando Goal Randomization wiki page in your web browser?"
     goalRandoWikiUrl="https://github.com/Die4Ever/deus-ex-randomizer/wiki/Goal-Randomization"
}
