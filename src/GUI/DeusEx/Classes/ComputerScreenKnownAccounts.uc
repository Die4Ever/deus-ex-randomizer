class ComputerScreenKnownAccounts extends #var(prefix)ComputerScreenHackAccounts;

var bool bShowPasswords;
var bool bOnlyShowKnownAccounts;
var bool bAllowLogin;
var localized string msgKnownPass;
var localized string msgUnknownPass;

var PersonaButtonBarWindow winActionButtons;
var MenuUIHeaderWindow userHdr, passHdr;

function CreateHeaders()
{
    local MenuUIHeaderWindow winHeader;

    winHeader = MenuUIHeaderWindow(NewChild(Class'MenuUIHeaderWindow'));
    winHeader.SetPos(12, 12);
    winHeader.SetText("Account List");

    userHdr = MenuUIHeaderWindow(NewChild(Class'MenuUIHeaderWindow'));
    userHdr.SetPos(16, 30);

    passHdr = MenuUIHeaderWindow(NewChild(Class'MenuUIHeaderWindow'));
    passHdr.SetPos(86, 30);

    SetColumnHeaders("User","Password");
}

function CreateAccountsList()
{
    local PersonaScrollAreaWindow winScroll;

    winScroll = PersonaScrollAreaWindow(NewChild(Class'PersonaScrollAreaWindow'));
    winScroll.SetPos(14, 42);
    winScroll.SetSize(170, 96); //Each selected row is 12 pixels tall, 8 accounts max

    lstAccounts = PersonaListWindow(winScroll.clipWindow.NewChild(Class'PersonaListWindow'));
    lstAccounts.EnableMultiSelect(False);
    lstAccounts.EnableAutoExpandColumns(False);
    lstAccounts.EnableHotKeys(False);
    lstAccounts.SetNumColumns(2);
    lstAccounts.SetColumnWidth(0, 68);
    lstAccounts.SetColumnWidth(1, 102);
}

function CreateControls()
{
    CreateChangeAccountButton();
    //CreateCurrentUserWindow();  //No longer needed
    CreateAccountsList();
    CreateHeaders();
}

function SetComputerHeaders()
{
    SetColumnHeaders("User","Password");
}

function SetATMHeaders()
{
    SetColumnHeaders("Account","PIN");
}

function SetColumnHeaders(string user, string pass)
{
    userHdr.SetText(user);
    passHdr.SetText(pass);
}

function ShowLoginButton(bool state)
{
    bAllowLogin = state;

    if (!state && btnChangeAccount!=None){
        btnChangeAccount.Destroy();
        winActionButtons.Destroy();
    } else if (state && btnChangeAccount==None){
        CreateChangeAccountButton();
    }
}

function UpdateCurrentUser()
{
    //This space intentionally left blank
}

function CreateChangeAccountButton()
{
    if (!bAllowLogin) return;

#ifdef gmdxae
    winActionButtons = PersonaButtonBarWindow(NewChild(Class'PersonaButtonBarWindowMenu'));
#else
	winActionButtons = PersonaButtonBarWindow(NewChild(Class'PersonaButtonBarWindow'));
#endif
    winActionButtons.SetPos(12, 142);
    winActionButtons.SetWidth(174);
    winActionButtons.FillAllSpace(False);

    CreateLoginButton();
}

function CreateLoginButton()
{
#ifdef gmdxae
    btnChangeAccount = PersonaActionButtonWindowMenu(winActionButtons.NewChild(Class'PersonaActionButtonWindowMenu'));
#else
    btnChangeAccount = PersonaActionButtonWindow(winActionButtons.NewChild(Class'PersonaActionButtonWindow'));
#endif
    btnChangeAccount.SetButtonText("Logi|&n");
    winActionButtons.SetWidth(btnChangeAccount.width);
}

function ChangeSelectedAccount()
{
    local string user,pass;

    if (!bAllowLogin) return;

    user = lstAccounts.GetField(lstAccounts.GetSelectedRow(),0);
    pass = lstAccounts.GetField(lstAccounts.GetSelectedRow(),1);

    if( pass == msgKnownPass || pass == msgUnknownPass )
        pass = "";
    if (winTerm != None){
#ifdef injections
        winTerm.LogInAs(user,pass);
#else
        if (DXRNetworkTerminalPersonal(winTerm)!=None){
            DXRNetworkTerminalPersonal(winTerm).LogInAs(user,pass);
        }
        if (DXRNetworkTerminalSecurity(winTerm)!=None){
            DXRNetworkTerminalSecurity(winTerm).LogInAs(user,pass);
        }
        if (DXRNetworkTerminalATM(winTerm)!=None){
            DXRNetworkTerminalATM(winTerm).LogInAs(user,pass);
        }
#endif
    }
}

function bool GetAccountKnown(#var(prefix)Computers comp, #var(prefix)ATM atm, int i, out string username, out string password)
{
#ifndef hx
    if( comp != None )
        username = Caps(comp.GetUserName(i));
    else if( atm != None )
        username = Caps(atm.GetAccountNumber(i));
#endif
#ifdef injections
    if( comp != None && comp.GetAccountKnown(i) ) {
        password = comp.GetPassword(i);
        return true;
    }
    else if( atm != None && atm.GetAccountKnown(i) ) {
        password = Caps(atm.GetPIN(i));
        return true;
    }
#else
    if( comp != None ) {
        if ( DXRComputerPersonal(comp)!=None && DXRComputerPersonal(comp).GetAccountKnown(i) ){
            password = DXRComputerPersonal(comp).GetPassword(i);
            return true;
        }
        if ( DXRComputerSecurity(comp)!=None && DXRComputerSecurity(comp).GetAccountKnown(i) ){
            password = DXRComputerSecurity(comp).GetPassword(i);
            return true;
        }
    }
    if( atm != None ) {
        if ( DXRATM(atm)!=None && DXRATM(atm).GetAccountKnown(i) ) {
            password = Caps(DXRATM(atm).GetPIN(i));
            return true;
        }
    }
#endif
    password = "";
    return false;
}

function SetCompOwner(#var(prefix)ElectronicDevices newCompOwner)
{
    local int compIndex;
    local int rowId;
    local int userRowIndex;
    local #var(prefix)ATM atm;
    local int numUsers;
    local string username, password;
    local bool known;

    compOwner = #var(prefix)Computers(newCompOwner);
    atm = #var(prefix)ATM(newCompOwner);

#ifndef hx
    if( compOwner != None ){
        numUsers = compOwner.NumUsers();
        SetComputerHeaders();
    } else if( atm != None ) {
        numUsers = atm.NumUsers();
        SetATMHeaders();
    }
#endif

    // Loop through the names and add them to our listbox
    for (compIndex=0; compIndex<numUsers; compIndex++)
    {
        known = GetAccountKnown(compOwner, atm, compIndex, username, password);

        if( known && ! bShowPasswords )
            password = msgKnownPass;
        else if( !known )
            password = msgUnknownPass;

        if (!bOnlyShowKnownAccounts || (bOnlyShowKnownAccounts && known)){
            lstAccounts.AddRow(username$";"$password);
        }

        if(known)
            userRowIndex = compIndex;
    }

    // Select the row that matches the current user
    rowId = lstAccounts.IndexToRowId(userRowIndex);
    lstAccounts.SetRow(rowId, True);
}

defaultproperties
{
    texBackground=Texture'ComputerKnownAccountsBackground'
    texBorder=Texture'ComputerKnownAccountsBorder'
    backgroundWidth=188
    backgroundHeight=153
    msgKnownPass="Known"
    msgUnknownPass="-----"
}
