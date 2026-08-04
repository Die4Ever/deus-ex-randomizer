class DXRComputerScreenHackAccounts injects #var(prefix)ComputerScreenHackAccounts;

//Duped from original class, but action button bar moved 1 pixel left and up to account for background pos change
function CreateChangeAccountButton()
{
    local PersonaButtonBarWindow winActionButtons;

    winActionButtons = PersonaButtonBarWindow(NewChild(Class'PersonaButtonBarWindow'));
    winActionButtons.SetPos(11, 168); //DXRANDO: changed coordinates
    winActionButtons.SetWidth(174);
    winActionButtons.FillAllSpace(False);

#ifdef gmdxae
    btnChangeAccount = PersonaActionButtonWindowMenu(winActionButtons.NewChild(Class'PersonaActionButtonWindowMenu'));
#else
    btnChangeAccount = PersonaActionButtonWindow(winActionButtons.NewChild(Class'PersonaActionButtonWindow'));
#endif
    btnChangeAccount.SetButtonText(ChangeAccountButtonLabel);

}

//DXRando: Always show username in caps
function UpdateCurrentUser()
{
    if (winTerm != None)
        winCurrentUser.SetText(Caps(winTerm.GetUserName()));
}


defaultproperties
{
    backgroundPosX=5 //Properly align the background to the border
    backgroundPosY=8
}
