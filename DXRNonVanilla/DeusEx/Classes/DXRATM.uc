class DXRATM injects #var(prefix)ATM;

var int knownAccount[8];

function bool GetAccountKnown(int userIndex)
{
	if ((userIndex >= 0) && (userIndex < ArrayCount(userList)))
		return knownAccount[userIndex]==1;

	return False;
}

function SetAccountKnown(int userIndex)
{
	if ((userIndex >= 0) && (userIndex < ArrayCount(userList)))
        knownAccount[userIndex]=1;
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
