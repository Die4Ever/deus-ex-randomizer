//=============================================================================
// DXRandoCrowdControlLink.
//=============================================================================
class DXRandoCrowdControlLink expands TcpLink config(DXRando);

var config int config_version;
var config bool enabled;

var transient DXRando dxr;
var int ListenPort;
var IpAddr addr;

var int reconnectTimer;
var int matrixModeTimer;
var int empTimer;
var int jumpTimer;
var int speedTimer;
var int lamthrowerTimer;

var float moveSpeedModifier;

const Success = 0;
const Failed = 1;
const NotAvail = 2;
const TempFail = 3;

const CrowdControlPort = 43384;

const MoveSpeedMultiplier = 10;
const MoveSpeedDivisor = 0.25;
const DefaultGroundSpeed = 320;

const ReconDefault = 5;
const MatrixTimeDefault = 60;
const EmpDefault = 15;
const JumpTimeDefault = 60;
const SpeedTimeDefault = 60;
const LamThrowerTimeDefault = 60;


function Init( DXRando tdxr)
{
    dxr = tdxr;    

    CheckConfig();

    if (!enabled) {
        return;
    }

    CleanupOnEnter();

    ListenPort=BindPort();
    if (ListenPort==0){
        dxr.Player.ClientMessage("Failed to bind port for Crowd Control");
        return;
    }   

    Resolve("localhost");

    reconnectTimer = ReconDefault;
    SetTimer(1,True);

}

function CheckConfig()
{

    if( config_version < class'DXRFlags'.static.VersionNumber() ) {
        log("INFO: upgraded config from "$config_version$" to "$class'DXRFlags'.static.VersionNumber());
        config_version = class'DXRFlags'.static.VersionNumber();
        SaveConfig();
    }
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
        dxr.Player.ClientMessage("Your powers fade...");
    }

}

function Timer() {
    if (!IsConnected()) {
        reconnectTimer-=1;
        if (reconnectTimer <= 0){
            Resolve("localhost");
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
            dxr.Player.ClientMessage("EMP Field has disappeared...");
        }
    }

    if (jumpTimer>0) {
        jumpTimer -= 1;
        dxr.Player.JumpZ = 0;
        if (jumpTimer <= 0) {
            dxr.Player.JumpZ = dxr.Player.Default.JumpZ;
            dxr.Player.ClientMessage("Your knees feel fine again.");
        }
    }

    if (speedTimer>0) {
        speedTimer-=1;
        dxr.Player.Default.GroundSpeed = DefaultGroundSpeed * moveSpeedModifier;
        if (speedTimer <= 0) {
            dxr.Player.Default.GroundSpeed = DefaultGroundSpeed;
            dxr.Player.ClientMessage("Back to normal speed!");
        }
    }

    if (lamthrowerTimer>0) {
        lamthrowerTimer-=1;
        if (lamthrowerTimer <=0) {
            UndoLamThrowers();
            dxr.Player.ClientMessage("Your flamethrower is boring again");
        }
    }

}

function bool isCrowdControl( string msg) {
    //Validate if it looks json-like
    if (InStr(msg,"{")!=0){
        //dxr.Player.ClientMessage("Message doesn't start with curly");
        return False;
    }
    
    if (InStr(msg,"}")!=Len(msg)-1){
        //dxr.Player.ClientMessage("Message doesn't end with curly");
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
    
    //dxr.Player.ClientMessage(resp);
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
		dxr.Player.ClientMessage(Sprintf(dxr.Player.SkillPointsAward, -numPoints));
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
    
    
    if (code=="poison"){
        dxr.Player.StartPoison(dxr.Player,5);
        dxr.Player.ClientMessage(viewer@"poisoned you!");

    } else if (code == "kill"){
        dxr.Player.Died(dxr.Player,'CrowdControl',v);
        dxr.Player.ClientMessage(viewer@"set off your killswitch!");
        dxr.Player.MultiplayerDeathMsg(dxr.Player,False,True,viewer,"triggering your kill switch");

    } else if (code == "drop_lam"){
        r.Yaw = 16000;
        Spawn(Class'LAM',,,dxr.Player.Location,r);
        dxr.Player.ClientMessage(viewer@"dropped a LAM at your feet!");

    } else if (code == "glass_legs") {
        dxr.Player.HealthLegLeft=1;
        dxr.Player.HealthLegRight=1;
        dxr.Player.GenerateTotalHealth();
        dxr.Player.ClientMessage(viewer@"gave you glass legs!");

    } else if (code == "give_health") {
        if (dxr.Player.Health == 100) {
            return TempFail;
        }
        dxr.Player.HealPlayer(50,False);
        dxr.Player.ClientMessage(viewer@"gave you 50 health!");

    } else if (code == "set_fire") {
        dxr.Player.CatchFire(dxr.Player);
        dxr.Player.ClientMessage(viewer@"set you on fire!");

    } else if (code == "give_medkit") {
        GiveItem(class'MedKit');
        dxr.Player.ClientMessage(viewer@"gave you a medkit");

    } else if (code == "send_player_to_random_point") {

    } else if (code == "full_heal") {
        if (dxr.Player.Health == 100) {
            return TempFail;
        }
        dxr.Player.RestoreAllHealth();
        dxr.Player.ClientMessage(viewer@"fully healed you!");

    } else if (code == "disable_jump") {
        if (dxr.Player.JumpZ == 0) {
            return TempFail;
        }

        dxr.Player.JumpZ = 0;
        jumpTimer = JumpTimeDefault;
        dxr.Player.ClientMessage(viewer@"made your knees lock up.");

    } else if (code == "gotta_go_fast") {
        if (DefaultGroundSpeed != dxr.Player.Default.GroundSpeed) {
            return TempFail;
        }
        moveSpeedModifier = MoveSpeedMultiplier;
        dxr.Player.Default.GroundSpeed = DefaultGroundSpeed * moveSpeedModifier;
        speedTimer = SpeedTimeDefault;
        dxr.Player.ClientMessage(viewer@"made you fast like Sonic!");

    } else if (code == "gotta_go_slow") {
        if (DefaultGroundSpeed != dxr.Player.Default.GroundSpeed) {
            return TempFail;
        }
        moveSpeedModifier = MoveSpeedDivisor;
        dxr.Player.Default.GroundSpeed = DefaultGroundSpeed * moveSpeedModifier;
        speedTimer = SpeedTimeDefault;
        dxr.Player.ClientMessage(viewer@"made you slow like a snail!");
    } else if (code == "drunk_mode") {
        if (dxr.Player.drugEffectTimer<30.0) {
            dxr.Player.drugEffectTimer+=60.0;
        } else {
            return TempFail;
        }
        dxr.Player.ClientMessage(viewer@"got you tipsy!");

    } else if (code == "drop_selected_item") {
        result = dxr.Player.DropItem();
        if (result == False) {
            return TempFail;
        }
        dxr.Player.ClientMessage(viewer@"made you fumble your item");

    } else if (code == "emp_field") {
        dxr.Player.bWarrenEMPField = true;
        empTimer = EmpDefault;
        dxr.Player.ClientMessage(viewer@"made electronics allergic to you");

    } else if (code == "matrix") {
        if (dxr.Player.Sprite!=None) {
            //Matrix Mode already enabled
            return TempFail;
        }
        dxr.Player.Matrix();
        matrixModeTimer = MatrixTimeDefault;
        dxr.Player.ClientMessage(viewer@"thinks you are The One...");
        

    } else if (code == "give_energy") {
        
        if (dxr.Player.Energy == dxr.Player.EnergyMax) {
            return TempFail;
        }
        //Copied from BioelectricCell

        //dxr.Player.ClientMessage("Recharged 10 points");
	dxr.Player.PlaySound(sound'BioElectricHiss', SLOT_None,,, 256);

	dxr.Player.Energy += 10;
	if (dxr.Player.Energy > dxr.Player.EnergyMax)
		dxr.Player.Energy = dxr.Player.EnergyMax;

        dxr.Player.ClientMessage(viewer@"gave you 10 energy!");

    } else if (code == "give_biocell") {
        GiveItem(class'BioelectricCell');
        dxr.Player.ClientMessage(viewer@"gave you a bioelectric cell!");

    } else if (code == "give_skillpoints") {
        dxr.Player.ClientMessage(viewer@"gave you skill points");
        dxr.Player.SkillPointsAdd(100);

    } else if (code == "remove_skillpoints") {
        dxr.Player.ClientMessage(viewer@"took away skill points");
        SkillPointsRemove(100);

    } else if (code == "lamthrower") {
        anItem = dxr.Player.FindInventoryType(class'WeaponFlamethrower');
        if (anItem==None) {
            return TempFail;
        }

        MakeLamThrower(anItem);
        lamthrowerTimer = LamThrowerTimeDefault;
        dxr.Player.ClientMessage(viewer@"turned your flamethrower into a LAM Thrower!");

    } else if (code == "give_flamethrower") {
        GiveItem(class'WeaponFlamethrower');
    } else if (code == "give_gep") {
        GiveItem(class'WeaponGEPGun');
    } else if (code == "give_dts") {
        GiveItem(class'WeaponNanoSword');
    } else if (code == "give_lam") {
        GiveItem(class'WeaponLAM');
    } else if (code == "give_emp") {
        GiveItem(class'WeaponEMPGrenade');
    } else if (code == "give_scrambler") {
        GiveItem(class'WeaponNanoVirusGrenade');
    } else if (code == "give_gas") {
        GiveItem(class'WeaponGasGrenade');
    } else if (code == "give_plasma") {
        GiveItem(class'WeaponPlasmaRifle');
    } else if (code == "give_law") {
        GiveItem(class'WeaponLAW');
    } else if (code == "give_aug_up") {
        GiveItem(class'AugmentationUpgradeCannister');

    } else {
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
        //dxr.Player.ClientMessage("Looks pretty crowd control-y to me");
        
        //Find ID
        loc1 = InStr(msg,"id");
        tmpstr1 = Mid(msg,loc1);
        loc1= InStr(tmpstr1,":");
        loc2= InStr(tmpstr1,",");
        length = loc2-loc1;
        tmpstr2 = Mid(tmpstr1,loc1+1,length);
        id = int(tmpstr2);
        //dxr.Player.ClientMessage("Crowd Control ID = "$id);
        
        //Find Code
        loc1 = InStr(msg,"code");
        tmpstr1 = Mid(msg,loc1);
        loc1= InStr(tmpstr1,":")+2;
        loc2= InStr(tmpstr1,",")-1;
        length = loc2-loc1;
        code = Mid(tmpstr1,loc1,length);
        //dxr.Player.ClientMessage("Crowd Control Code = "$code);        
        
        //Find Viewer
        loc1 = InStr(msg,"viewer");
        tmpstr1 = Mid(msg,loc1);
        loc1= InStr(tmpstr1,":")+2;
        loc2= InStr(tmpstr1,",")-1;
        length = loc2-loc1;
        viewer = Mid(tmpstr1,loc1,length);
        //dxr.Player.ClientMessage("Crowd Control Viewer = "$viewer);

        //Find Type
        loc1 = InStr(msg,"type");
        tmpstr1 = Mid(msg,loc1);
        loc1= InStr(tmpstr1,":");
        loc2= InStr(tmpstr1,"}");
        length = loc2-loc1;
        tmpstr2 = Mid(tmpstr1,loc1+1,length);
        type = int(tmpstr2);
        //dxr.Player.ClientMessage("Crowd Control Type = "$type);     
        
        result = doCrowdControlEvent(code,viewer,type);
        
        sendReply(id,result);   
        
    } else {
        dxr.Player.ClientMessage("Got a weird message: "$msg);
    }

}

event ReceivedText ( string Text ) {
    //dxr.Player.ClientMessage(Text);
    handleMessage(Text);
}

event Opened(){
    dxr.Player.ClientMessage("Crowd Control connection opened");
}

event Closed(){
    dxr.Player.ClientMessage("Crowd Control connection closed");
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
            dxr.Player.ClientMessage("Failed to bind port for Crowd Control");
            reconnectTimer = ReconDefault;
            return;
        }   
    }

    Addr.port=CrowdControlPort;
    if (False==Open(Addr)){
        dxr.Player.ClientMessage("Could not connect to Crowd Control client");
        reconnectTimer = ReconDefault;
        return;

    }

    LinkMode=MODE_Text;
}
function ResolveFailed()
{
    dxr.Player.ClientMessage("Could not resolve Crowd Control address");
    reconnectTimer = ReconDefault;
}
