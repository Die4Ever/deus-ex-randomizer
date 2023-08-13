class DXRComputerScreenATM injects ComputerScreenATM;

function CloseScreen(String action)
{
    local int compIndex;

    if (action=="LOGIN")
    {
        //Mark the account as known
#ifdef injections
        ATM(compOwner).SetAccountKnownByName(editAccount.GetText());
#else
        DXRATM(compOwner).SetAccountKnownByName(editAccount.GetText());

#endif
    }

#ifdef injections
    winTerm.CloseKnownAccountsWindow();
#else
    if(DXRNetworkTerminalATM(winTerm)!=None){
        DXRNetworkTerminalATM(winTerm).CloseKnownAccountsWindow();
    }
#endif

	Super.CloseScreen(action);
}

function SetNetworkTerminal(NetworkTerminal newTerm)
{
	Super.SetNetworkTerminal(newTerm);

#ifdef injections
    winTerm.CreateKnownAccountsWindow();
#else
    if(DXRNetworkTerminalATM(winTerm)!=None){
        DXRNetworkTerminalATM(winTerm).CreateKnownAccountsWindow();
    }
#endif
}
