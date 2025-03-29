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

//Don't delete the username when a login fails.  This makes it easier
//to try again if you mistype a password or something (or the ATM in
//the Paris metro station where the password is incomplete...).  Reset
//the cursor in the password box after failed login.
function ProcessLogin()
{
    local string acctNum;

    acctNum=editAccount.GetText();
    Super.ProcessLogin();
    if (winLoginError.GetText()==InvalidLoginMessage){
        //If the login succeeds, this ends up populating the
        //withdraw field with the account number
        editAccount.SetText(acctNum);
        SetFocusWindow(editPIN);
    }
}
