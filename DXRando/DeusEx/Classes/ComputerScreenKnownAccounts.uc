class ComputerScreenKnownAccounts extends ComputerScreenHackAccounts;

function CreateHeaders()
{
	local MenuUIHeaderWindow winHeader;

	winHeader = MenuUIHeaderWindow(NewChild(Class'MenuUIHeaderWindow'));
	winHeader.SetPos(12, 12);
	winHeader.SetText("Last Login");

	winHeader = MenuUIHeaderWindow(NewChild(Class'MenuUIHeaderWindow'));
	winHeader.SetPos(12, 53);
	winHeader.SetText("Known Accounts");
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

	if (winTerm != None)
        winTerm.LogInAs(user,pass);
}

function SetCompOwner(ElectronicDevices newCompOwner)
{
	local int compIndex;
	local int rowId;
	local int userRowIndex;
    local ATM atm;

    if (newCompOwner.IsA('Computers'))
    {
        compOwner = Computers(newCompOwner);

        // Loop through the names and add them to our listbox
        for (compIndex=0; compIndex<compOwner.NumUsers(); compIndex++)
        {
            if (compOwner.GetAccountKnown(compIndex)) {
                lstAccounts.AddRow(Caps(compOwner.GetUserName(compIndex))$";"$compOwner.GetPassword(compIndex));

                if (Caps(winTerm.GetUserName()) == Caps(compOwner.GetUserName(compIndex)))
                    userRowIndex = compIndex;
            }
        }
    }
    else if (newCompOwner.IsA('ATM'))
    {
        atm = ATM(newCompOwner);

        // Loop through the names and add them to our listbox
        for (compIndex=0; compIndex<atm.NumUsers(); compIndex++)
        {
            log("ATM has account "$atm.GetAccountNumber(compIndex));
            if (atm.GetAccountKnown(compIndex)) {
                lstAccounts.AddRow(Caps(atm.GetAccountNumber(compIndex))$";"$atm.GetPIN(compIndex));

                if (Caps(winTerm.GetUserName()) == Caps(atm.GetAccountNumber(compIndex)))
                    userRowIndex = compIndex;
            }
        }   
    }

	// Select the row that matches the current user
	rowId = lstAccounts.IndexToRowId(userRowIndex);
	lstAccounts.SetRow(rowId, True);
}

