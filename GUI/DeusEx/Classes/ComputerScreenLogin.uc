class DXRComputerScreenLogin injects #var(prefix)ComputerScreenLogin;

function CloseScreen(String action)
{
    local int compIndex;

    if (action=="LOGIN")
    {
#ifdef injections
        //Mark the account as known
        Computers(compOwner).SetAccountKnownByName(editUserName.GetText());
#else
        if (DXRComputerPersonal(compOwner)!=None){
            DXRComputerPersonal(compOwner).SetAccountKnownByName(editUserName.GetText());
        }
#endif
    }

#ifdef injections
    winTerm.CloseKnownAccountsWindow();
#else
    if(DXRNetworkTerminalPersonal(winTerm)!=None){
        DXRNetworkTerminalPersonal(winTerm).CloseKnownAccountsWindow();
    }
    if(DXRNetworkTerminalSecurity(winTerm)!=None){
        DXRNetworkTerminalSecurity(winTerm).CloseKnownAccountsWindow();
    }
#endif

	Super.CloseScreen(action);
}

function SetNetworkTerminal(#var(prefix)NetworkTerminal newTerm)
{
	Super.SetNetworkTerminal(newTerm);

#ifdef injections
    winTerm.CreateKnownAccountsWindow();
#else
    if(DXRNetworkTerminalPersonal(winTerm)!=None){
        DXRNetworkTerminalPersonal(winTerm).CreateKnownAccountsWindow();
    }
    if(DXRNetworkTerminalSecurity(winTerm)!=None){
        DXRNetworkTerminalSecurity(winTerm).CreateKnownAccountsWindow();
    }
#endif
}

//Don't delete the username when a login fails.  This makes it easier
//to try again if you mistype a password or something (or the ATM in
//the Paris metro station where the password is incomplete...).  Reset
//the cursor in the password box after failed login.
function ProcessLogin()
{
    local string userName;

    userName=editUserName.GetText();
    Super.ProcessLogin();
    editUserName.SetText(userName);
    SetFocusWindow(editPassword);
}
