class DXRPersonaImageGoalHintWindow expands PersonaImageNoteWindow;

//You clicked on the window!
event bool MouseButtonPressed(float pointX, float pointY, EInputKey button,
                              int numClicks)
{
    local DXRDataVaultMapImageNote note;

    note = DXRDataVaultMapImageNote(GetNote());

    if (note==None){
        return false;
    }

    class'BingoHintMsgBox'.static.Create(DeusExRootWindow(player.rootWindow), note.HelpTitle, note.HelpText, 1, False, self);
    return true;
}

event bool BoxOptionSelected(Window msgBoxWindow, int buttonNumber)
{
    // Destroy the msgbox!
	DeusExRootWindow(player.rootWindow).PopWindow();

	return True;
}
