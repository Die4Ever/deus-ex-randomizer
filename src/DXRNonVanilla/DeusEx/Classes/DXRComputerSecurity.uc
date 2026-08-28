//=============================================================================
// DXRComputerSecurity.
//=============================================================================
class DXRComputerSecurity extends #var(prefix)ComputerSecurity;

var int knownAccount[8];

#ifdef revision
function bool Facelift(bool bOn)
{
    local DXRando dxr;

    dxr = class'DXRando'.default.dxr;

    if (dxr!=None && class'MenuChoice_GoalTextures'.static.IsEnabled()){
        return false;
    } else if (dxr==None && Skin==Texture'GoalSecurityComputerGreen'){
        return false; //On a load, DXR may not be there yet
    }

    return Super.Facelift(bOn);
}
#endif

function bool GetAccountKnown(int userIndex)
{
    if ((userIndex >= 0) && (userIndex < ArrayCount(userList)))
        return knownAccount[userIndex]==1;

    return False;
}

//Push known passwords into an active computer terminal if open
function UpdateKnownAccountWindow()
{
    local DXRNetworkTerminalSecurity dxrterm;

    dxrterm = DXRNetworkTerminalSecurity(termwindow);
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

function bool GetAccountKnownByName(String username)
{
    return GetAccountKnown(GetAccountIndexByName(username));
}

function SetAccountKnownByPassword(String password)
{
    SetAccountKnown(GetAccountIndexByPass(password));
}

function bool GetAccountKnownByPassword(String password)
{
    return GetAccountKnown(GetAccountIndexByPass(password));
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

#ifdef gmdxae

//Override GMDX:AE checks to feed it with our own knowledge of the password
//Theoretically this could maybe actually try to check if you have the note, etc.  Future TODO, I guess
function bool IsDiscovered(DeusExPlayer player, string code, optional string code2, optional bool bReallyKnown)
{
    //Code is the Username, Code2 is the password
    local DXRando dxr;

    dxr = class'DXRando'.default.dxr;

    if (dxr!=None && dxr.flags!=None && dxr.flags.settings.passwordsrandomized > 0 && GetAccountKnownByName(code)){
        return true;
    }

    Super.IsDiscovered(player,code,code2,bReallyKnown);
}

function bool IsDefaultSkin()
{
    return Skin==Default.Skin || Skin==Default.ActivatedSkin || String(Skin)==HDTPSkin;
}

function AdditionalActivation(DeusExPlayer ActivatingPlayer)
{
    local Texture tex;
    local bool changed;

    if (!IsDefaultSkin()){
        tex = Skin;
        changed = true;
    }
    Super.AdditionalActivation(ActivatingPlayer);
    if (changed){
        Skin = tex;
    }
}

function AdditionalDeactivation(DeusExPlayer DeactivatingPlayer)
{
    local Texture tex;
    local bool changed;

    if (!IsDefaultSkin()){
        tex = Skin;
        changed = true;
    }
    Super.AdditionalDeactivation(DeactivatingPlayer);
    if (changed){
        Skin = tex;
    }
}
#endif

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
     terminalType=Class'#var(package).DXRNetworkTerminalSecurity'
}
