//=============================================================================
// DXRandoCrowdControlLink.
//=============================================================================
class DXRandoCrowdControlLink expands TcpLink transient;

var string crowd_control_addr;

var transient DXRando dxr;
var int ListenPort;
var IpAddr addr;

var int reconnectTimer;
var int matrixModeTimer;
var int empTimer;
var int jumpTimer;
var int speedTimer;
var int lamthrowerTimer;
var int iceTimer;

var float moveSpeedModifier;
var string pendingMsg;

const Success = 0;
const Failed = 1;
const NotAvail = 2;
const TempFail = 3;

const CrowdControlPort = 43384;

const MoveSpeedMultiplier = 10;
const MoveSpeedDivisor = 0.25;
const DefaultGroundSpeed = 320;

//HK Canal freezer room has friction=1, but that doesn't
//feel slippery enough to me
const IceFriction = 0.25; //Standard friction is 8

const ReconDefault = 5;
const MatrixTimeDefault = 60;
const EmpDefault = 15;
const JumpTimeDefault = 60;
const SpeedTimeDefault = 60;
const LamThrowerTimeDefault = 60;
const IceTimeDefault = 60;


function Init( DXRando tdxr, string addr)
{
    dxr = tdxr;   
    crowd_control_addr = addr; 

    CleanupOnEnter();

    /*ListenPort=BindPort();
    if (ListenPort==0){
        err("Failed to bind port for Crowd Control");
        return;
    }*/

    Resolve(crowd_control_addr);

    reconnectTimer = ReconDefault;
    SetTimer(1,True);

}


function CleanupOnEnter() {

    //Clean up Matrix Mode if enabled
    StopMatrixMode(True);

    //Clean up EMP field if previously active
    dxr.Player.bWarrenEMPField = false;

    //Clean up move speed, since it seems to follow through levels
    dxr.Player.Default.GroundSpeed = DefaultGroundSpeed;

}

function StopMatrixMode(optional bool silent) {
    if (dxr.Player.Sprite!=None) {
        dxr.Player.Matrix();
    }

    if (!silent) {
        PlayerMessage("Your powers fade...");
    }

}

function Timer() {
    if (!IsConnected()) {
        reconnectTimer-=1;
        if (reconnectTimer <= 0){
            Resolve(crowd_control_addr);
        }
    }

    //Matrix Mode Timer
    if (matrixModeTimer>0) {
        matrixModeTimer-=1;
        if (matrixModeTimer == 0) {
            StopMatrixMode();
        }
    }

    //EMP Field timer
    if (empTimer>0) {
        empTimer -= 1;
        if (empTimer <=0) {
            dxr.Player.bWarrenEMPField = false;
            PlayerMessage("EMP Field has disappeared...");
        }
    }

    if (jumpTimer>0) {
        jumpTimer -= 1;
        dxr.Player.JumpZ = 0;
        if (jumpTimer <= 0) {
            dxr.Player.JumpZ = dxr.Player.Default.JumpZ;
            PlayerMessage("Your knees feel fine again.");
        }
    }

    if (speedTimer>0) {
        speedTimer-=1;
        dxr.Player.Default.GroundSpeed = DefaultGroundSpeed * moveSpeedModifier;
        if (speedTimer <= 0) {
            dxr.Player.Default.GroundSpeed = DefaultGroundSpeed;
            PlayerMessage("Back to normal speed!");
        }
    }

    if (lamthrowerTimer>0) {
        lamthrowerTimer-=1;
        if (lamthrowerTimer <=0) {
            UndoLamThrowers();
            PlayerMessage("Your flamethrower is boring again");
        }
    }
	
	if (iceTimer>0) {
		iceTimer-=1;
		if (iceTimer<=0) {
		    SetIcePhysics(False);
			PlayerMessage("The ground thaws");
		}
	}

}

function bool isCrowdControl( string msg) {
    local string tmp;
    //Validate if it looks json-like
    if (InStr(msg,"{")!=0){
        //PlayerMessage("Message doesn't start with curly");
        return False;
    }
    
    if (InStr(msg,"}")!=Len(msg)-1){
        //PlayerMessage("Message doesn't end with curly");
        return False;    
    }
    
    //Check to see if it looks like it has the right fields in it
    
    //id field
    if (InStr(msg,"id")==-1){
        return False;
    }
    
    //code field
    if (InStr(msg,"code")==-1){
        return False;
    }    
    //viewer field
    if (InStr(msg,"viewer")==-1){
        return False;
    }   
    //type field
    if (InStr(msg,"type")==-1){
        return False;
    }
    
    //Check to see if there are multiple messages stuck together
    //By removing the outermost curly brackets, we can check to
    //see if there are any more inside them (indicating one was
    //closed and another one was opened within the same message
    tmp = Mid(msg,1,Len(msg)-2);
    //PlayerMessage("Removed outer curlies: "$tmp);
    //Check for extra curly braces inside the outermost ones
    if (InStr(tmp,"{")!=-1){
        //PlayerMessage("Has extra internal open curly!");
        return False;
    }
    
    if (InStr(tmp,"}")!=-1){
        //PlayerMessage("Has extra internal close curly!");
        return False;    
    }

    return True;
}

function sendReply(int id, int status) {
    local string resp;
    local byte respbyte[255];
    local int i;
    
    resp = "{\"id\":"$id$",\"status\":"$status$"}"; 
    
    for (i=0;i<Len(resp);i++){
        respbyte[i]=Asc(Mid(resp,i,1));
    }
    
    //PlayerMessage(resp);
    SendBinary(Len(resp)+1,respbyte);
}

function bool IsGrenade(inventory i) {
    return (i.IsA('WeaponLAM') || i.IsA('WeaponGasGrenade') || i.IsA ('WeaponEMPGrenade') || i.IsA('WeaponNanoVirusGrenade'));
}

function GiveItem(class<Inventory> c) {
    local inventory anItem;
    anItem=Spawn(c);
    anItem.SetLocation(dxr.Player.Location);
    
    //Grenades apparently don't like HandleItemPickup, so we'll frob them
    if (anItem.IsA('DeusExWeapon') && !IsGrenade(anItem)) {
        dxr.Player.HandleItemPickup(anItem);
    } else {
        anItem.Frob(dxr.Player,None);
    }
}

function SkillPointsRemove(int numPoints) {
	dxr.Player.SkillPointsAvail -= numPoints;
	dxr.Player.SkillPointsTotal -= numPoints;

	if ((DeusExRootWindow(dxr.Player.rootWindow) != None) &&
	    (DeusExRootWindow(dxr.Player.rootWindow).hud != None) && 
		(DeusExRootWindow(dxr.Player.rootWindow).hud.msgLog != None))
	{
		PlayerMessage(Sprintf(dxr.Player.SkillPointsAward, -numPoints));
		DeusExRootWindow(dxr.Player.rootWindow).hud.msgLog.PlayLogSound(Sound'LogSkillPoints');
	}
}

function UndoLamThrowers () {
    local WeaponFlamethrower f;
    foreach AllActors(class'WeaponFlamethrower', f)
    {
        f.ProjectileClass = f.Default.ProjectileClass;
        f.beltDescription = f.Default.beltDescription;
    }
}

function MakeLamThrower (inventory anItem) {
    local WeaponFlamethrower f;

    //Just in case we somehow pass something else in here...
    if (anItem.IsA('WeaponFlamethrower') == False) {
        return;
    }

    f = WeaponFlamethrower(anItem);
    f.ProjectileClass = class'LAM';
    f.beltDescription = "LAMTHWR";
}

//"Why not just use "GivePlayerAugmentation", you ask.
//While it works well to give the player an aug they don't
//have, it won't actually upgrade their augs if they don't 
//already have an aug upgrade canister in their inventory.
//This can also return better status messages for crowd control
function int GiveAug(Class<Augmentation> giveClass, string viewer) {
    local Augmentation anAug;
	local bool wasActive;
	
	// Checks to see if the player already has it.  If so, we want to 
	// increase the level
	anAug = dxr.Player.AugmentationSystem.FindAugmentation(giveClass);
	
	if (anAug == None) {
	   PlayerMessage(viewer@"tried to give you an aug that doesn't exist?");
	   return Failed; //Shouldn't happen
	}
	
	if (anAug.bHasIt)
	{
	    //Upgrade scenario
	    if (!(anAug.CurrentLevel < anAug.MaxLevel)) {
		    PlayerMessage(viewer@"wanted to upgrade "$anAug.AugmentationName$" but it cannot be upgraded any further");
			return Failed;
		}
	    wasActive = anAug.bIsActive;
		if (anAug.bIsActive) {
		   anAug.Deactivate();
		}
		
		anAug.CurrentLevel++;
		
		//Since this upgrade wasn't player initiated, it would be nice to reactivate it again for them
		if (wasActive) {
		    anAug.Activate();
		}
		
		PlayerMessage(viewer@"upgraded "$anAug.AugmentationName$" to level "$anAug.CurrentLevel+1);
        return Success;
	}
	
	if(dxr.Player.AugmentationSystem.AreSlotsFull(anAug)) {
	    PlayerMessage(viewer@"wanted to give you "$anAug.AugmentationName$" but there is no room");
		return Failed;
	}
	
	anAug.bHasIt = True;
	
	if (anAug.bAlwaysActive)
	{
		anAug.bIsActive = True;
		anAug.GotoState('Active');
	}
	else
	{
		anAug.bIsActive = False;
	}	
	
	// Manage our AugLocs[] array
	dxr.Player.AugmentationSystem.AugLocs[anAug.AugmentationLocation].augCount++;
	
	// Assign hot key to new aug 
	// (must be after before augCount is incremented!)
    anAug.HotKeyNum = dxr.Player.AugmentationSystem.AugLocs[anAug.AugmentationLocation].augCount + dxr.Player.AugmentationSystem.AugLocs[anAug.AugmentationLocation].KeyBase;


	if ((!anAug.bAlwaysActive) && (dxr.Player.bHUDShowAllAugs))
	    dxr.Player.AddAugmentationDisplay(anAug);	
    PlayerMessage(viewer@"gave you the "$anAug.AugmentationName$" augmentation");
    return Success;
}

//This just doesn't normally exist
function int RemoveAug(Class<Augmentation> giveClass, string viewer) {
    local Augmentation anAug;
	local bool wasActive;
	
	// Checks to see if the player already has it, so we can decrease the level,
	// or remove it all together
	anAug = dxr.Player.AugmentationSystem.FindAugmentation(giveClass);
	
	if (anAug == None) {
	   PlayerMessage(viewer@"tried to remove an aug that doesn't exist?");
	   return Failed; //Shouldn't happen
	}
	
	if (!anAug.bHasIt)
	{
		PlayerMessage(viewer@"wanted to remove "$anAug.AugmentationName$" but you didn't have it");
	    return Failed;	    
	}
	
	if (anAug.CurrentLevel > 0) {
	    //Downgrade scenario, has aug above base level
	    
	    wasActive = anAug.bIsActive;
		if (anAug.bIsActive) {
		   anAug.Deactivate();
		}
		
		anAug.CurrentLevel--;
		
		//Since this downgrade wasn't player initiated, it would be nice to reactivate it again for them		
		if (wasActive) {
		    anAug.Activate();
		}
		
		PlayerMessage(viewer@"downgraded "$anAug.AugmentationName$" to level "$anAug.CurrentLevel+1);
        return Success;
	}
	
	anAug.Deactivate();
	anAug.bHasIt = False;
	
	// Manage our AugLocs[] array
	dxr.Player.AugmentationSystem.AugLocs[anAug.AugmentationLocation].augCount--;
	
	//Icon lookup is BY HOTKEY, so make sure to remove the icon before the hotkey
	dxr.Player.RemoveAugmentationDisplay(anAug);
	// Assign hot key back to default
    anAug.HotKeyNum = anAug.Default.HotKeyNum;

	

    PlayerMessage(viewer@"removed your "$anAug.AugmentationName$" augmentation");
    return Success;
}

function SetIcePhysics(bool enabled) {
	local ZoneInfo Z;
	ForEach AllActors(class'ZoneInfo', Z)
	    if (enabled) {
	        //I doubt the default is actually being used for anything, so I'll
		    //take it and use it as my own personal info storage space
	        Z.Default.ZoneGroundFriction = Z.ZoneGroundFriction;
		    Z.ZoneGroundFriction = IceFriction;
		} else {
		    Z.ZoneGroundFriction = Z.Default.ZoneGroundFriction;	
		}
}

function int doCrowdControlEvent(string code, string viewer, int type) {
    local vector v;
    local rotator r;
    local inventory anItem;
    local bool result;
    v.X=0;
    v.Y=0;
    v.Z=0;
    r.Pitch = 0;
    r.Yaw = 0;
    r.Roll =0;
    
    switch(code) {
		case "poison":
			dxr.Player.StartPoison(dxr.Player,5);
			PlayerMessage(viewer@"poisoned you!");
			break;

		case "kill":
			dxr.Player.Died(dxr.Player,'CrowdControl',v);
			PlayerMessage(viewer@"set off your killswitch!");
			dxr.Player.MultiplayerDeathMsg(dxr.Player,False,True,viewer,"triggering your kill switch");
			break;

		case "drop_lam":
			r.Yaw = 16000;
			Spawn(Class'LAM',,,dxr.Player.Location,r);
			PlayerMessage(viewer@"dropped a LAM at your feet!");
			break;

		case "glass_legs":
			dxr.Player.HealthLegLeft=1;
			dxr.Player.HealthLegRight=1;
			dxr.Player.GenerateTotalHealth();
			PlayerMessage(viewer@"gave you glass legs!");
			break;

		case "give_health":
			if (dxr.Player.Health == 100) {
				return TempFail;
			}
			dxr.Player.HealPlayer(50,False);
			PlayerMessage(viewer@"gave you 50 health!");
			break;

		case "set_fire":
			dxr.Player.CatchFire(dxr.Player);
			PlayerMessage(viewer@"set you on fire!");
			break;

		case "give_medkit":
			GiveItem(class'MedKit');
			PlayerMessage(viewer@"gave you a medkit");
			break;

		case "full_heal":
			if (dxr.Player.Health == 100) {
				return TempFail;
			}
			dxr.Player.RestoreAllHealth();
			PlayerMessage(viewer@"fully healed you!");
			break;

		case "disable_jump":
			if (dxr.Player.JumpZ == 0) {
				return TempFail;
			}

			dxr.Player.JumpZ = 0;
			jumpTimer = JumpTimeDefault;
			PlayerMessage(viewer@"made your knees lock up.");
			break;

		case "gotta_go_fast":
			if (DefaultGroundSpeed != dxr.Player.Default.GroundSpeed) {
				return TempFail;
			}
			moveSpeedModifier = MoveSpeedMultiplier;
			dxr.Player.Default.GroundSpeed = DefaultGroundSpeed * moveSpeedModifier;
			speedTimer = SpeedTimeDefault;
			PlayerMessage(viewer@"made you fast like Sonic!");
			break;

		case "gotta_go_slow":
			if (DefaultGroundSpeed != dxr.Player.Default.GroundSpeed) {
				return TempFail;
			}
			moveSpeedModifier = MoveSpeedDivisor;
			dxr.Player.Default.GroundSpeed = DefaultGroundSpeed * moveSpeedModifier;
			speedTimer = SpeedTimeDefault;
			PlayerMessage(viewer@"made you slow like a snail!");
			break;
		case "drunk_mode":
			if (dxr.Player.drugEffectTimer<30.0) {
				dxr.Player.drugEffectTimer+=60.0;
			} else {
				return TempFail;
			}
			PlayerMessage(viewer@"got you tipsy!");
			break;

		case "drop_selected_item":
			result = dxr.Player.DropItem();
			if (result == False) {
				return TempFail;
			}
			PlayerMessage(viewer@"made you fumble your item");
			break;

		case "emp_field":
			dxr.Player.bWarrenEMPField = true;
			empTimer = EmpDefault;
			PlayerMessage(viewer@"made electronics allergic to you");
			break;

		case "matrix":
			if (dxr.Player.Sprite!=None) {
				//Matrix Mode already enabled
				return TempFail;
			}
			dxr.Player.Matrix();
			matrixModeTimer = MatrixTimeDefault;
			PlayerMessage(viewer@"thinks you are The One...");
			break;
			

		case "give_energy":
			
			if (dxr.Player.Energy == dxr.Player.EnergyMax) {
				return TempFail;
			}
			//Copied from BioelectricCell

			//PlayerMessage("Recharged 10 points");
		dxr.Player.PlaySound(sound'BioElectricHiss', SLOT_None,,, 256);

		dxr.Player.Energy += 10;
		if (dxr.Player.Energy > dxr.Player.EnergyMax)
			dxr.Player.Energy = dxr.Player.EnergyMax;

			PlayerMessage(viewer@"gave you 10 energy!");
			break;

	   case "give_biocell":
			GiveItem(class'BioelectricCell');
			PlayerMessage(viewer@"gave you a bioelectric cell!");
			break;

		case "give_skillpoints":
			PlayerMessage(viewer@"gave you skill points");
			dxr.Player.SkillPointsAdd(100);
			break;

		case "remove_skillpoints":
			PlayerMessage(viewer@"took away skill points");
			SkillPointsRemove(100);
			break;

		case "lamthrower":
			anItem = dxr.Player.FindInventoryType(class'WeaponFlamethrower');
			if (anItem==None) {
				return TempFail;
			}

			MakeLamThrower(anItem);
			lamthrowerTimer = LamThrowerTimeDefault;
			PlayerMessage(viewer@"turned your flamethrower into a LAM Thrower!");
			break;

		case "give_flamethrower":
			GiveItem(class'WeaponFlamethrower');
			break;

		case "give_gep":
			GiveItem(class'WeaponGEPGun');
			break;

		case "give_dts":
			GiveItem(class'WeaponNanoSword');
			break;

		case "give_lam":
			GiveItem(class'WeaponLAM');
			break;

		case "give_emp":
			GiveItem(class'WeaponEMPGrenade');
			break;

		case "give_scrambler":
			GiveItem(class'WeaponNanoVirusGrenade');
			break;

		case "give_gas":
			GiveItem(class'WeaponGasGrenade');
			break;

		case "give_plasma":
			GiveItem(class'WeaponPlasmaRifle');
			break;

		case "give_law":
			GiveItem(class'WeaponLAW');
			break;

		case "give_ps40":
			GiveItem(class'WeaponHideAGun');
			break;

		case "give_aug_up":
			GiveItem(class'AugmentationUpgradeCannister');
			break;
			
		case "up_aqualung":
		    return GiveAug(class'AugAqualung',viewer);
			break;			
		case "up_ballistic":
		    return GiveAug(class'AugBallistic',viewer);
			break;			
		case "up_cloak":
		    return GiveAug(class'AugCloak',viewer);
			break;			
		case "up_combat":
		    return GiveAug(class'AugCombat',viewer);
			break;			
		case "up_defense":
		    return GiveAug(class'AugDefense',viewer);
			break;			
		case "up_drone":
		    return GiveAug(class'AugDrone',viewer);
			break;			
		case "up_emp":
		    return GiveAug(class'AugEmp',viewer);
			break;			
		case "up_enviro":
		    return GiveAug(class'AugEnviro',viewer);
			break;			
		case "up_healing":
		    return GiveAug(class'AugHealing',viewer);
			break;			
		case "up_heartlung":
		    return GiveAug(class'AugHeartLung',viewer);
			break;			
		case "up_muscle":
		    return GiveAug(class'AugMuscle',viewer);
			break;	
		case "up_power":
		    return GiveAug(class'AugPower',viewer);
			break;			
		case "up_radartrans":
		    return GiveAug(class'AugRadarTrans',viewer);
			break;			
		case "up_shield":
		    return GiveAug(class'AugShield',viewer);
			break;			
		case "up_speed":
		    return GiveAug(class'AugSpeed',viewer);
			break;			
		case "up_stealth":
		    return GiveAug(class'AugStealth',viewer);
			break;			
		case "up_target":
		    return GiveAug(class'AugTarget',viewer);
			break;			
		case "up_vision":
		    return GiveAug(class'AugVision',viewer);
			break;

		case "down_aqualung":
		    return RemoveAug(class'AugAqualung',viewer);
			break;			
		case "down_ballistic":
		    return RemoveAug(class'AugBallistic',viewer);
			break;			
		case "down_cloak":
		    return RemoveAug(class'AugCloak',viewer);
			break;			
		case "down_combat":
		    return RemoveAug(class'AugCombat',viewer);
			break;			
		case "down_defense":
		    return RemoveAug(class'AugDefense',viewer);
			break;			
		case "down_drone":
		    return RemoveAug(class'AugDrone',viewer);
			break;			
		case "down_emp":
		    return RemoveAug(class'AugEmp',viewer);
			break;			
		case "down_enviro":
		    return RemoveAug(class'AugEnviro',viewer);
			break;			
		case "down_healing":
		    return RemoveAug(class'AugHealing',viewer);
			break;			
		case "down_heartlung":
		    return RemoveAug(class'AugHeartLung',viewer);
			break;			
		case "down_muscle":
		    return RemoveAug(class'AugMuscle',viewer);
			break;	
		case "down_power":
		    return RemoveAug(class'AugPower',viewer);
			break;			
		case "down_radartrans":
		    return RemoveAug(class'AugRadarTrans',viewer);
			break;			
		case "down_shield":
		    return RemoveAug(class'AugShield',viewer);
			break;			
		case "down_speed":
		    return RemoveAug(class'AugSpeed',viewer);
			break;			
		case "down_stealth":
		    return RemoveAug(class'AugStealth',viewer);
			break;			
		case "down_target":
		    return RemoveAug(class'AugTarget',viewer);
			break;			
		case "down_vision":
		    return RemoveAug(class'AugVision',viewer);
			break;
        
        case "ice_physics":
		    if (iceTimer!=0) {
				return TempFail;
			}
		    PlayerMessage(viewer@"made the ground freeze!");
		    SetIcePhysics(True);
			iceTimer = IceTimeDefault;
            break;		


		case "send_player_to_random_point":
		default:
			return NotAvail;
    }
    return Success;
}

function handleMessage( string msg) {
    local int loc1,loc2,length;
    local string tmpstr1,tmpstr2;
    
    local int id,type;
    local string code,viewer;
    
    local int result;

    if (isCrowdControl(msg)) {
        //Yolo
        //PlayerMessage("Looks pretty crowd control-y to me");
        
        //Find ID
        loc1 = InStr(msg,"id");
        tmpstr1 = Mid(msg,loc1);
        loc1= InStr(tmpstr1,":");
        loc2= InStr(tmpstr1,",");
        length = loc2-loc1;
        tmpstr2 = Mid(tmpstr1,loc1+1,length);
        id = int(tmpstr2);
        //PlayerMessage("Crowd Control ID = "$id);
        
        //Find Code
        loc1 = InStr(msg,"code");
        tmpstr1 = Mid(msg,loc1);
        loc1= InStr(tmpstr1,":")+2;
        loc2= InStr(tmpstr1,",")-1;
        length = loc2-loc1;
        code = Mid(tmpstr1,loc1,length);
        //PlayerMessage("Crowd Control Code = "$code);        
        
        //Find Viewer
        loc1 = InStr(msg,"viewer");
        tmpstr1 = Mid(msg,loc1);
        loc1= InStr(tmpstr1,":")+2;
        loc2= InStr(tmpstr1,",")-1;
        length = loc2-loc1;
        viewer = Mid(tmpstr1,loc1,length);
        //PlayerMessage("Crowd Control Viewer = "$viewer);

        //Find Type
        loc1 = InStr(msg,"type");
        tmpstr1 = Mid(msg,loc1);
        loc1= InStr(tmpstr1,":");
        loc2= InStr(tmpstr1,"}");
        length = loc2-loc1;
        tmpstr2 = Mid(tmpstr1,loc1+1,length);
        type = int(tmpstr2);
        //PlayerMessage("Crowd Control Type = "$type);     
        
        result = doCrowdControlEvent(code,viewer,type);
        
        sendReply(id,result);
        
    } else {
        err("Got a weird message: "$msg);
    }

}

event ReceivedText ( string Text ) {
    //Text mode seems to just drop anything past a null terminator
    //so if multiple messages are received back to back before
    //we get around to reading it, any past the first may be
    //discarded entirely
    handleMessage(Text);
}

//In the context of crowd control, this behaves the same as ReceivedText
//This is because there are no linebreaks in the messages, they are just
//null terminated
event ReceivedLine ( string Text ) {
    handleMessage(Text);
}


//This seems to just receive crazy garbage
event ReceivedBinary(int count, byte B[255]) {
    local int i;
    for (i = 0; i < count; i++) {
        if (B[i] == 0) {
            //handleMessage(pendingMsg);
            if (Len(pendingMsg)>0){
            //PlayerMessage("got message (maybe): "$pendingMsg);
            }
            pendingMsg="";
        } else {
            pendingMsg = pendingMsg $ Chr(B[i]);
            PlayerMessage("ReceivedBinary: " $ B[i]);
        }
    }
    PlayerMessage("Count was "$count);
}

event Opened(){
    PlayerMessage("Crowd Control connection opened");
}

event Closed(){
    PlayerMessage("Crowd Control connection closed");
    ListenPort = 0;
    reconnectTimer = ReconDefault;
}

event Destroyed(){
    Close();
    Super.Destroyed();
}

function Resolved( IpAddr Addr )
{
    if (ListenPort == 0) {
        ListenPort=BindPort();
        if (ListenPort==0){
            err("Failed to bind port for Crowd Control");
            reconnectTimer = ReconDefault;
            return;
        }   
    }

    Addr.port=CrowdControlPort;
    if (False==Open(Addr)){
        err("Could not connect to Crowd Control client");
        reconnectTimer = ReconDefault;
        return;

    }

    LinkMode=MODE_Text;

}
function ResolveFailed()
{
    err("Could not resolve Crowd Control address");
    reconnectTimer = ReconDefault;
}

function PlayerMessage(string msg)
{
    log(Self$": "$msg);
    class'Telemetry'.static.SendLog(Self, "INFO", msg);
    dxr.Player.ClientMessage(msg);
}

function err(string msg)
{
    log(Self$": ERROR: "$msg);
    class'Telemetry'.static.SendLog(Self, "ERROR", msg);
    dxr.Player.ClientMessage(msg);
}

function info(string msg)
{
    log(Self$": INFO: "$msg);
    class'Telemetry'.static.SendLog(Self, "INFO", msg);
}
