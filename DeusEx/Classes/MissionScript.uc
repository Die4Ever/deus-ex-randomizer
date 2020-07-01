//=============================================================================
// MissionScript.
//=============================================================================
class MissionScript extends Info
	transient
	abstract;

//
// State machine for each mission
// All flags set by this mission controller script should be
// prefixed with MS_ for consistency
//

var float checkTime;
var DeusExPlayer Player;
var FlagBase flags;
var string localURL;
var DeusExLevelInfo dxInfo;

// ----------------------------------------------------------------------
// PostPostBeginPlay()
//
// Set the timer
// ----------------------------------------------------------------------

function PostPostBeginPlay()
{
	// start the script
	SetTimer(checkTime, True);
}

// ----------------------------------------------------------------------
// InitStateMachine()
//
// Get the player's flag base, get the map name, and set the player
// ----------------------------------------------------------------------

function InitStateMachine()
{
	local DeusExLevelInfo info;

	Player = DeusExPlayer(GetPlayerPawn());

	foreach AllActors(class'DeusExLevelInfo', info)
		dxInfo = info;

	if (Player != None)
	{
		flags = Player.FlagBase;

		// Get the mission number by extracting it from the
		// DeusExLevelInfo and then delete any expired flags.
		//
		// Also set the default mission expiration so flags
		// expire in the next mission unless explicitly set
		// differently when the flag is created.

		if (flags != None)
		{
			// Don't delete expired flags if we just loaded
			// a savegame
			if (flags.GetBool('PlayerTraveling'))
				flags.DeleteExpiredFlags(dxInfo.MissionNumber);

			flags.SetDefaultExpiration(dxInfo.MissionNumber + 1);

			localURL = Caps(dxInfo.mapName);

			log("**** InitStateMachine() -"@player@"started mission state machine for"@localURL);
		}
		else
		{
			log("**** InitStateMachine() - flagBase not set - mission state machine NOT initialized!");
		}
	}
	else
	{
		log("**** InitStateMachine() - player not set - mission state machine NOT initialized!");
	}
}

// ----------------------------------------------------------------------
// FirstFrame()
// 
// Stuff to check at first frame
// ----------------------------------------------------------------------

function FirstFrame()
{
	local name flagName;
	local ScriptedPawn P;
	local int i;

	flags.DeleteFlag('PlayerTraveling', FLAG_Bool);

	// Check to see which NPCs should be dead from prevous missions
	foreach AllActors(class'ScriptedPawn', P)
	{
		if (P.bImportant)
		{
			flagName = Player.rootWindow.StringToName(P.BindName$"_Dead");
			if (flags.GetBool(flagName))
				P.Destroy();
		}
	}

	// print the mission startup text only once per map
	flagName = Player.rootWindow.StringToName("M"$Caps(dxInfo.mapName)$"_StartupText");
	if (!flags.GetBool(flagName))
	{
        Rando();
        if (dxInfo.startupMessage[0] != "")
        {
    		for (i=0; i<ArrayCount(dxInfo.startupMessage); i++)
	    		DeusExRootWindow(Player.rootWindow).hud.startDisplay.AddMessage(dxInfo.startupMessage[i]);
		    DeusExRootWindow(Player.rootWindow).hud.startDisplay.StartMessage();
        }
		flags.SetBool(flagName, True);
	}

	flagName = Player.rootWindow.StringToName("M"$dxInfo.MissionNumber$"MissionStart");
	if (!flags.GetBool(flagName))
	{
		// Remove completed Primary goals and all Secondary goals
		Player.ResetGoals();

		// Remove any Conversation History.
		Player.ResetConversationHistory();

		// Set this flag so we only get in here once per mission.
		flags.SetBool(flagName, True);
	}
}

// ----------------------------------------------------------------------
// PreTravel()
// 
// Set flags upon exit of a certain map
// ----------------------------------------------------------------------

function PreTravel()
{
	// turn off the timer
	SetTimer(0, False);

	// zero the flags so FirstFrame() gets executed at load
	flags = None;
}

// ----------------------------------------------------------------------
// Timer()
//
// Main state machine for the mission
// ----------------------------------------------------------------------

function Timer()
{
	// make sure our flags are initialized correctly
	if (flags == None)
	{
		InitStateMachine();

		// Don't want to do this if the user just loaded a savegame
		if ((player != None) && (flags.GetBool('PlayerTraveling')))
			FirstFrame();
	}
}

// ----------------------------------------------------------------------
// GetPatrolPoint()
// ----------------------------------------------------------------------

function PatrolPoint GetPatrolPoint(Name patrolTag, optional bool bRandom)
{
	local PatrolPoint aPoint;

	aPoint = None;

	foreach AllActors(class'PatrolPoint', aPoint, patrolTag)
	{
		if (bRandom && (FRand() < 0.5))
			break;
		else
			break;
	}

	return aPoint;
}

// ----------------------------------------------------------------------
// GetSpawnPoint()
// ----------------------------------------------------------------------

function SpawnPoint GetSpawnPoint(Name spawnTag, optional bool bRandom)
{
	local SpawnPoint aPoint;

	aPoint = None;

	foreach AllActors(class'SpawnPoint', aPoint, spawnTag)
	{
		if (bRandom && (FRand() < 0.5))
			break;
		else
			break;
	}

	return aPoint;
}

function Rando()
{
    local ScriptedPawn p;
    local DeusExCarcass c;
    local Weapon inv;

    //Player.SkillPointsAvail = 0;
    //Player.SkillPointsTotal = 0;

    if(Player != None) Player.ClientMessage("randomizing "$Caps(dxInfo.mapName)$"");

    SwapAll('Inventory');
    SwapAll('Containers');

    RandomizeAugCannisters();

    /*foreach AllActors(class'ScriptedPawn', p)
    {
        if( p.bIsPlayer ) continue;
        inv = spawn(class'WeaponAssaultGun');
        inv.GiveTo(p);
        inv.SetBase(p);

        inv.AmmoType = spawn(inv.AmmoName);
        inv.AmmoType.InitialState='Idle2';
        inv.AmmoType.GiveTo(p);
        inv.AmmoType.SetBase(p);

        p.SetupWeapon(false);
    }*/

    /*foreach AllActors(class'DeusExCarcass', c)
    {
        inv = spawn(class'WeaponAssaultGun', self);
        c.AddInventory(inv);
    }*/

    if(Player != None) Player.ClientMessage("done randomizing "$Caps(dxInfo.mapName)$"");
}

function SwapAll(name classname)
{
    local Actor a, b;
    local int num, i, slot;
    num=0;
    foreach AllActors(class'Actor', a )
    {
        if( SkipActor(a, classname) ) continue;
        num++;
    }

    foreach AllActors(class'Actor', a )
    {
        if( SkipActor(a, classname) ) continue;

        i=0;
        slot=Rand(num-1);
        //if(Player != None) Player.ClientMessage(""$a.Class$"");
        foreach AllActors(class'Actor', b )
        {
            if( SkipActor(b, classname) ) continue;

            if(i==slot) {
                Swap(a, b);
                break;
            }
            i++;
        }
    }
}

function bool SkipActor(Actor a, name classname)
{
    return ( ! a.IsA(classname) ) || ( Pawn(a.Owner) != None ) || a.bStatic || a.bHidden;
}

function Swap(Actor a, Actor b)
{
    local vector newloc;
    local rotator newrot;

    newloc = b.Location + (a.CollisionHeight - b.CollisionHeight) * vect(0,0,1);
    newrot = b.Rotation;

    b.SetLocation(a.Location + (b.CollisionHeight - a.CollisionHeight) * vect(0,0,1) );
    b.SetRotation(a.Rotation);

    a.SetLocation(newloc);
    a.SetRotation(newrot);

    //a.SetPhysics(PHYS_Falling);
    //b.SetPhysics(PHYS_Falling);
}

function RandomizeAugCannisters()
{
    local AugmentationCannister a;
    local int augIndex;
    local int numAugs;

    if( Player == None ) return;

    numAugs=0;

    for(augIndex=0; augIndex<arrayCount(Player.AugmentationSystem.augClasses); augIndex++)
    {
        if (Player.AugmentationSystem.augClasses[augIndex] != None)
        {
            numAugs=augIndex+1;
        }
    }

    foreach AllActors(class'AugmentationCannister', a)
    {
        a.AddAugs[0] = PickRandomAug(numAugs);
        a.AddAugs[1] = PickRandomAug(numAugs);
        //Player.ClientMessage("0: " $a.AddAugs[0]$ ", 1: " $a.AddAugs[1]$ "");
    }
}

function Name PickRandomAug(int numAugs)
{
    local int slot;
    slot = Rand(numAugs-1);
    //Player.ClientMessage("slot: "$slot$"");
    return Player.AugmentationSystem.augClasses[slot].Name;
}

defaultproperties
{
     checkTime=1.000000
     localURL="NOTHING"
}
