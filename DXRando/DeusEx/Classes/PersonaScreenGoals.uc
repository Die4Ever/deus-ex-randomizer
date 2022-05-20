#ifdef injections
class PersonaScreenGoals injects PersonaScreenGoals;
#else
class DXRPersonaScreenGoals extends PersonaScreenGoals;
#endif

var PersonaActionButtonWindow btnBingo;

function CreateControls()
{
    Super.CreateControls();
    btnBingo = PersonaActionButtonWindow(winClient.NewChild(Class'PersonaActionButtonWindow'));
    btnBingo.SetButtonText("|&Bingo");
    btnBingo.SetPos(545, 1);
    btnBingo.SetSensitivity(true);
}

function bool ButtonActivated( Window buttonPressed )
{
    if(buttonPressed == btnBingo) {
        SaveSettings();
        root.InvokeUIScreen(class'PersonaScreenBingo');
        return true;
    }
    return Super.ButtonActivated(buttonPressed);
}
