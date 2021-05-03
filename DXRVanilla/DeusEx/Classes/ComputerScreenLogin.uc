class DXRComputerScreenLogin injects ComputerScreenLogin;

function CloseScreen(String action)
{
    local int compIndex;
    
    if (action=="LOGIN")
    {
        //Mark the account as known
        Computers(compOwner).SetAccountKnownByName(editUserName.GetText());
    }
    
    winTerm.CloseKnownAccountsWindow();

	Super.CloseScreen(action);
}

function SetNetworkTerminal(NetworkTerminal newTerm)
{
	Super.SetNetworkTerminal(newTerm);
    
    winTerm.CreateKnownAccountsWindow();
}
