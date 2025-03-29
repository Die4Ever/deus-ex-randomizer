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
//(Copied vanilla function, but don't clear the account field)
function ProcessLogin()
{
    local bool bSuccessfulLogin;
    local int  accountIndex;
    local int  userIndex;

    bSuccessfulLogin = False;

    for (accountIndex=0; accountIndex<atmOwner.NumUsers(); accountIndex++)
    {
        if (Caps(editAccount.GetText()) == atmOwner.GetAccountNumber(accountIndex))
        {
            userIndex = accountIndex;
            break;
        }
    }

    if (userIndex != -1)
    {
        if (Caps(editPIN.GetText()) == atmOwner.GetPIN(userIndex))
            bSuccessfulLogin = True;
    }

    if (bSuccessfulLogin)
    {
        winTerm.SetLoginInfo("", userIndex);
        CloseScreen("LOGIN");
    }
    else
    {
        // Print a message about invalid login
        winLoginError.SetText(InvalidLoginMessage);

        // Clear PIN field and focus on it
        //editAccount.SetText("");
        editPIN.SetText("");
        SetFocusWindow(editPIN);
    }
}

