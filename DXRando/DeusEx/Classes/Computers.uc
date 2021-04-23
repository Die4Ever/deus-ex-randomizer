class DXRComputers injects Computers;

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
    
	for (compIndex=0; compIndex<NumUsers(); compIndex++)
	{
		if (Caps(username) == Caps(GetUserName(compIndex)))
		{
            return compIndex;
        }
    }
    return -1;
}

function int GetAccountIndexByPass(string password)
{
    local int compIndex;
    
	for (compIndex=0; compIndex<NumUsers(); compIndex++)
	{
		if (Caps(password) == Caps(GetPassword(compIndex)))
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

/////////////////////////////////////////////////////////////
///////////////States copied from base class/////////////////
//////Including these allows old save games to load//////////
/////////////////////////////////////////////////////////////

// ----------------------------------------------------------------------
// state On
// ----------------------------------------------------------------------

state On
{
	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);

		if (bOn)
		{
			if ((termwindow == None) && (Level.NetMode == NM_Standalone))
         {
				GotoState('Off');
         }            
         if (curFrobber == None)
         {
            GotoState('Off');
         }
         else if (VSize(curFrobber.Location - Location) > 1500)
         {
            log("Disabling computer "$Self$" because user "$curFrobber$" was too far away");
			//Probably should be "GotoState('Off')" instead, but no good way to test, so I'll leave it alone.
            curFrobber = None;
         }
		}
	}

Begin:
	if (!bOn)
	{
      AdditionalActivation(curFrobber);
		bAnimating = True;
		PlayAnim('Activate');
		FinishAnim();
		bOn = True;
		bAnimating = False;
		ChangePlayerVisibility(False);
      TryInvoke();
	}
}

// ----------------------------------------------------------------------
// state Off
// ----------------------------------------------------------------------

auto state Off
{
Begin:
	if (bOn)
	{
      AdditionalDeactivation(curFrobber);
		ChangePlayerVisibility(True);
		bAnimating = True;
		PlayAnim('Deactivate');
		FinishAnim();
		bOn = False;
		bAnimating = False;
		if (bLockedOut)
			BeginAlarm();

		// Resume any datalinks that may have started while we were 
		// in the computers (don't want them to start until we pop back out)
		ResumeDataLinks();
      curFrobber = None;
	}
}
