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
//(Copied vanilla function, but don't clear the username field)
function ProcessLogin()
{
    local string userName;
    local int userIndex;
    local int compIndex;
    local int userSkillLevel;
    local bool bSuccessfulLogin;

    bSuccessfulLogin = False;
    userIndex        = -1;

    // Verify that this is a valid userid/password combination

    // First check the name
    for (compIndex=0; compIndex<Computers(compOwner).NumUsers(); compIndex++)
    {
        if (Caps(editUsername.GetText()) == Caps(Computers(compOwner).GetUserName(compIndex)))
        {
            userName  = Caps(Computers(compOwner).GetUserName(compIndex));
            userIndex = compIndex;
            break;
        }
    }

    if (userIndex != -1)
    {
        if (Caps(editPassword.GetText()) == Caps(Computers(compOwner).GetPassword(userIndex)))
        {
            bSuccessfulLogin = True;
        }
    }

    if (bSuccessfulLogin)
    {
        winTerm.SetLoginInfo(userName, userIndex);

        // set the user's access level if it's higher than the player's
        userSkillLevel = Computers(compOwner).GetAccessLevel(userIndex);

        if (winTerm.GetSkillLevel() < userSkillLevel)
            winTerm.SetSkillLevel(userSkillLevel);

        CloseScreen("LOGIN");
    }
    else
    {
        // Print a message about invalid login
        winLoginInfo.SetText(InvalidLoginMessage);

        // Clear text fields and reset focus
        //editUserName.SetText("");
        editPassword.SetText("");
        SetFocusWindow(editPassword);
    }
}

