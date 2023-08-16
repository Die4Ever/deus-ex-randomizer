class DXRComputerScreenATM injects #var(prefix)ComputerScreenATM;

function CloseScreen(String action)
{
    local int compIndex;

    if (action=="LOGIN")
    {
        //Mark the account as known
        #var(injectsprefix)ATM(compOwner).SetAccountKnownByName(editAccount.GetText());
    }

    if(#var(injectsprefix)NetworkTerminalATM(winTerm)!=None){
        #var(injectsprefix)NetworkTerminalATM(winTerm).CloseKnownAccountsWindow();
    }

    Super.CloseScreen(action);
}

function SetNetworkTerminal(#var(prefix)NetworkTerminal newTerm)
{
	Super.SetNetworkTerminal(newTerm);

    if(#var(injectsprefix)NetworkTerminalATM(winTerm)!=None){
        #var(injectsprefix)NetworkTerminalATM(winTerm).CreateKnownAccountsWindow();
    }
}
