class DXRPersonaImageGoalHintWindow expands PersonaImageNoteWindow;

//You clicked on the window!
event bool MouseButtonPressed(float pointX, float pointY, EInputKey button,
                              int numClicks)
{
    local BingoHintMsgBox msgbox;
    local DXRDataVaultMapImageNote note;

    note = DXRDataVaultMapImageNote(GetNote());

    if (note==None){
        return false;
    }
    
    msgbox = BingoHintMsgBox(DeusExRootWindow(player.rootWindow).PushWindow(class'BingoHintMsgBox',False));
    msgbox.SetTitle(note.HelpTitle);
    msgbox.SetMessageText(note.HelpText);
    msgbox.SetNotifyWindow(Self);

	return true;
}

event bool BoxOptionSelected(Window msgBoxWindow, int buttonNumber)
{
    // Destroy the msgbox!
	DeusExRootWindow(player.rootWindow).PopWindow();

	return True;
}