//=============================================================================
// DXRComputerPersonal.
//=============================================================================
class DXRComputerPersonal extends #var(prefix)ComputerPersonal;

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

function int GetAccountIndexByName(string username)
{
    local int compIndex;

    username = Caps(username);
    for (compIndex=0; compIndex<NumUsers(); compIndex++)
    {
        if (username == Caps(GetUserName(compIndex)))
        {
            return compIndex;
        }
    }
    return -1;
}

function int GetAccountIndexByPass(string password)
{
    local int compIndex;

    password = Caps(password);
    for (compIndex=0; compIndex<NumUsers(); compIndex++)
    {
        if (password == Caps(GetPassword(compIndex)))
        {
            log("Found password "$password$" in computer "$Name);
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

#ifdef hx
//To simplify making this compile cleanly...
function int NumUsers()
{
    return 0;
}

function string GetPassword(int userIndex)
{
    return "";
}

function string GetUserName(int userIndex)
{
    return "";
}
#endif

defaultproperties
{
     terminalType=Class'#var(package).DXRNetworkTerminalPersonal'
}
