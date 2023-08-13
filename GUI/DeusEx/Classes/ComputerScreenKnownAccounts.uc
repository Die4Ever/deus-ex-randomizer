class ComputerScreenKnownAccounts extends ComputerScreenHackAccounts;

var bool bShowPasswords;
var localized string msgKnownPass;
var localized string msgUnknownPass;

function CreateHeaders()
{
    local MenuUIHeaderWindow winHeader;

    winHeader = MenuUIHeaderWindow(NewChild(Class'MenuUIHeaderWindow'));
    winHeader.SetPos(12, 12);
    winHeader.SetText("Last Login");

    winHeader = MenuUIHeaderWindow(NewChild(Class'MenuUIHeaderWindow'));
    winHeader.SetPos(12, 53);
    winHeader.SetText("Accounts");
}

function CreateAccountsList()
{
    local PersonaScrollAreaWindow winScroll;

    winScroll = PersonaScrollAreaWindow(NewChild(Class'PersonaScrollAreaWindow'));;
    winScroll.SetPos(14, 69);
    winScroll.SetSize(170, 97);

    lstAccounts = PersonaListWindow(winScroll.clipWindow.NewChild(Class'PersonaListWindow'));
    lstAccounts.EnableMultiSelect(False);
    lstAccounts.EnableAutoExpandColumns(False);
    lstAccounts.EnableHotKeys(False);
    lstAccounts.SetNumColumns(2);
    lstAccounts.SetColumnWidth(0, 80);
    lstAccounts.SetColumnWidth(1, 80);
}

function CreateControls()
{
    CreateChangeAccountButton();
    CreateCurrentUserWindow();
    CreateAccountsList();
    CreateHeaders();
}

function CreateChangeAccountButton()
{
    local PersonaButtonBarWindow winActionButtons;

    winActionButtons = PersonaButtonBarWindow(NewChild(Class'PersonaButtonBarWindow'));
    winActionButtons.SetPos(12, 169);
    winActionButtons.SetWidth(174);
    winActionButtons.FillAllSpace(False);

    btnChangeAccount = PersonaActionButtonWindow(winActionButtons.NewChild(Class'PersonaActionButtonWindow'));
    btnChangeAccount.SetButtonText("Login");
}

function ChangeSelectedAccount()
{
    local string user,pass;

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
#endif
    }
}

function bool GetAccountKnown(Computers comp, ATM atm, int i, out string username, out string password)
{
    if( comp != None )
        username = Caps(comp.GetUserName(i));
    else if( atm != None )
        username = Caps(atm.GetAccountNumber(i));
#ifdef injections
    if( comp != None && comp.GetAccountKnown(i) ) {
        password = Caps(comp.GetPassword(i));
        return true;
    }
    else if( atm != None && atm.GetAccountKnown(i) ) {
        password = Caps(atm.GetPIN(i));
        return true;
    }
#else
    if( comp != None ) {
        if ( DXRComputerPersonal(comp)!=None && DXRComputerPersonal(comp).GetAccountKnown(i) ){
            password = Caps(DXRComputerPersonal(comp).GetPassword(i));
            return true;
        }
        if ( DXRComputerSecurity(comp)!=None && DXRComputerSecurity(comp).GetAccountKnown(i) ){
            password = Caps(DXRComputerSecurity(comp).GetPassword(i));
            return true;
        }
    }
#endif
    password = "";
    return false;
}

function SetCompOwner(ElectronicDevices newCompOwner)
{
    local int compIndex;
    local int rowId;
    local int userRowIndex;
    local ATM atm;
    local int numUsers;
    local string username, password;
    local bool known;

    compOwner = Computers(newCompOwner);
    atm = ATM(newCompOwner);

    if( compOwner != None )
        numUsers = compOwner.NumUsers();
    else if( atm != None )
        numUsers = atm.NumUsers();

    // Loop through the names and add them to our listbox
    for (compIndex=0; compIndex<numUsers; compIndex++)
    {
        known = GetAccountKnown(compOwner, atm, compIndex, username, password);

        if( known && ! bShowPasswords )
            password = msgKnownPass;
        else if( !known )
            password = msgUnknownPass;

        lstAccounts.AddRow(username$";"$password);

        if (Caps(winTerm.GetUserName()) == username)
            userRowIndex = compIndex;
    }

    // Select the row that matches the current user
    rowId = lstAccounts.IndexToRowId(userRowIndex);
    lstAccounts.SetRow(rowId, True);
}

defaultproperties
{
    msgKnownPass="Known"
    msgUnknownPass="Unknown"
}
