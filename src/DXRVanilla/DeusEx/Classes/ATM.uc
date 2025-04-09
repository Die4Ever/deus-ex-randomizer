class DXRATM injects ATM;

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
