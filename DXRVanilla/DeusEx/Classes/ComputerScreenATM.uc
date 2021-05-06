class DXRComputerScreenATM injects ComputerScreenATM;

function CloseScreen(String action)
{
    local int compIndex;
    
    if (action=="LOGIN")
    {
        //Mark the account as known
        ATM(compOwner).SetAccountKnownByName(editAccount.GetText());
    }
    
    winTerm.CloseKnownAccountsWindow();

	Super.CloseScreen(action);
}

function SetNetworkTerminal(NetworkTerminal newTerm)
{
	Super.SetNetworkTerminal(newTerm);
    
    winTerm.CreateKnownAccountsWindow();
}
