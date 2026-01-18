class DXRATM injects #var(prefix)ATM;

var int knownAccount[8];

function bool GetAccountKnown(int userIndex)
{
	if ((userIndex >= 0) && (userIndex < ArrayCount(userList)))
		return knownAccount[userIndex]==1;

	return False;
}

//Push known passwords into an active computer terminal if open
function UpdateKnownAccountWindow()
{
    local DXRNetworkTerminalATM dxrterm;

    #ifdef hx
    dxrterm = DXRNetworkTerminalATM(termwindow);
    #else
    dxrterm = DXRNetworkTerminalATM(atmwindow);
    #endif
    if (dxrterm==None) return;
    if (dxrterm.winKnownAccounts==None) return;

    dxrterm.winKnownAccounts.PopulateAccountList();
}

function SetAccountKnown(int userIndex)
{
	if ((userIndex >= 0) && (userIndex < ArrayCount(userList)))
        knownAccount[userIndex]=1;

    UpdateKnownAccountWindow();
}

function SetAccountKnownByName(String username)
{
    SetAccountKnown(GetAccountIndexByName(username));
}

function SetAccountKnownByPassword(String password)
{
    SetAccountKnown(GetAccountIndexByPass(password));
}

function int GetAccountIndexByName(string accountNum)
{
    local int compIndex;

	for (compIndex=0; compIndex<NumUsers(); compIndex++)
	{
		if (Caps(accountNum) == Caps(GetAccountNumber(compIndex)))
		{
            return compIndex;
        }
    }
    return -1;
}

function int GetAccountIndexByPass(string pin)
{
    local int compIndex;

	for (compIndex=0; compIndex<NumUsers(); compIndex++)
	{
		if (Caps(pin) == Caps(GetPIN(compIndex)))
		{
            log("Found password "$pin$" in computer "$Name);
            return compIndex;
        }
    }
    return -1;
}

function bool HasKnownAccounts()
{
    local int compIndex;

	for (compIndex=0; compIndex<NumUsers(); compIndex++)
	{
        if (knownAccount[compIndex]==1) {
            return True;
        }
    }
    return False;
}

#ifndef hx

function int FindAccountIdxOnOtherATM(ATM other, string account, string pin)
{
    local int i;

    account = Caps(account);
    pin = Caps(pin);

    if (account=="") return -1;
    if (pin=="") return -1;

    for(i=0;i<ArrayCount(other.UserList);i++)
    {
        if (account!=other.GetAccountNumber(i)) continue;
        if (pin!=other.GetPIN(i)) continue;
        return i;
    }
    return -1;
}

//Rewritten sync logic so that it actually works when hacking.
//Balance can no longer go below 0, because debt isn't real.
function ModBalance(int userIndex, int numCredits, bool bSync)
{
    local ATM atm;
    local int i,idx;

    //p.ClientMessage(self$".ModBalance idx "$userIndex$"  numCredits "$numCredits$"  Sync:"$bSync);

    if ((userIndex >= 0) && (userIndex < ArrayCount(userList))){
        userList[userIndex].balance -= numCredits;
        userList[userIndex].balance = Max(0,userList[userIndex].balance);
    }
    else if (userIndex == -1)
    {
        // if we've been hacked, zero all the accounts if we have enough to transfer
        for (i=0; i<ArrayCount(userList); i++)
            userList[i].balance = 0;
        numCredits=99999; //Make sure the accounts are drained when they're synced
    }

    // sync the balance with all other ATMs on this map
    if (bSync)
    {
        foreach AllActors(class'ATM', atm){
            if (atm==self) continue;

            for (i=0; i<NumUsers(); i++){
                idx = FindAccountIdxOnOtherATM(atm,userList[i].accountNumber,userList[i].PIN);
                if (idx != -1){
                    atm.ModBalance(idx, numCredits, False);
                }
            }
        }
    }
}

//Copied from vanilla, but now with a different UI screen
function Frob(Actor Frobber, Inventory frobWith)
{
	local DeusExPlayer Player;
	local DeusExRootWindow root;
	local float elapsed, delay;

	Super(#var(prefix)ElectronicDevices).Frob(Frobber, frobWith);

	// if we're already using this ATM, get out
	if (atmwindow != None)
		return;

	Player = DeusExPlayer(Frobber);

	if (Player != None)
	{
		if (bLockedOut)
		{
			// computer skill shortens the lockout duration
			delay = lockoutDelay / Player.SkillSystem.GetSkillLevelValue(class'SkillComputer');

			elapsed = Level.TimeSeconds - lockoutTime;
			if (elapsed < delay)
				Player.ClientMessage(Sprintf(msgLockedOut, Int(delay - elapsed)));
			else
				bLockedOut = False;
		}
		if (!bLockedOut)
		{
			root = DeusExRootWindow(Player.rootWindow);
			if (root != None)
			{
				atmWindow = ATMWindow(root.InvokeUIScreen(Class'DXRNetworkTerminalATM', True));
				if (atmWindow != None)
				{
					atmWindow.SetCompOwner(Self);
					atmWindow.ShowFirstScreen();
				}
			}
		}
	}
}
#endif
