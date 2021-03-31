//=============================================================================
// DXRandoCrowdControlLink.
//=============================================================================
class DXRandoCrowdControlLink extends TcpLink transient;

var string crowd_control_addr;

var DXRCrowdControl ccModule;

var DataStorage datastorage;
var transient DXRando dxr;
var int ListenPort;
var IpAddr addr;

var int ticker;
var int lavaTick;

var bool anon;

var int reconnectTimer;

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
const IceFriction = 0.25;
const NormalFriction = 8;
var vector NormalGravity;
var vector FloatGrav;
var vector MoonGrav;

const ReconDefault = 5;
const MatrixTimeDefault = 60;
const EmpDefault = 15;
const JumpTimeDefault = 60;
const SpeedTimeDefault = 60;
const LamThrowerTimeDefault = 60;
const IceTimeDefault = 60;
const BehindTimeDefault = 60;
const DifficultyTimeDefault = 60;
const FloatyTimeDefault = 60;
const FloorLavaTimeDefault = 60;
const InvertMouseTimeDefault = 60;
const InvertMovementTimeDefault = 60;

struct ZoneFriction
{
    var name zonename;
    var float friction;
};
var ZoneFriction zone_frictions[32];

struct ZoneGravity
{
    var name zonename;
    var vector gravity;
};
var ZoneGravity zone_gravities[32];

var DXRandoCrowdControlTimer timerDisplays[32];

//JSON parsing states
const KeyState = 1;
const ValState = 2;
const ArrayState = 3;
const ArrayDoneState = 4;

struct JsonElement
{
    var string key;
    var string value[5];
    var int valCount;
};

struct JsonMsg
{
    var JsonElement e[20];
    var int count;
};

function string StripQuotes (string msg) {
    if (Mid(msg,0,1)==Chr(34)) {
        if (Mid(msg,Len(Msg)-1,1)==Chr(34)) {
            return Mid(msg,1,Len(msg)-2);
        }
    }        
    return msg;
}

function string JsonStripSpaces(string msg) {
    local int i;
    local string c;
    local string buf;
    local bool inQuotes;
    
    inQuotes = False;
    
    for (i = 0; i < Len(msg) ; i++) {
        c = Mid(msg,i,1); //Grab a single character
        
        if (c==" " && !inQuotes) {
            continue;  //Don't add spaces to the buffer if we're outside quotes
        } else if (c==Chr(34)) {
            inQuotes = !inQuotes;
        }
        
        buf = buf $ c;
    }    
    
    return buf;
}

//Returns the appropriate character for whatever is after
//the backslash, eg \c
function string JsonGetEscapedChar(string c) {
    switch(c){
        case "b":
            return Chr(8); //Backspace
        case "f":
            return Chr(12); //Form feed
        case "n":
            return Chr(10); //New line
        case "r":
            return Chr(13); //Carriage return
        case "t":
            return Chr(9); //Tab
        case Chr(34): //Quotes
        case Chr(92): //Backslash
            return c;
        default:
            return "";
    }
}

function JsonMsg ParseJson (string msg) {
    
    local bool msgDone;
    local int i;
    local string c;
    local string buf;
    
    local int parsestate;
    local bool inquotes;
    local bool escape;
    
    local JsonMsg j;
    
    local bool elemDone;
    
    elemDone = False;
    
    parsestate = KeyState;
    inquotes = False;
    escape = False;
    msgDone = False;
    buf = "";

    //Strip any spaces outside of strings to standardize the input a bit
    msg = JsonStripSpaces(msg);
    
    for (i = 0; i < Len(msg) && !msgDone ; i++) {
        c = Mid(msg,i,1); //Grab a single character
        
        if (!inQuotes) {
            switch (c) {
                case ":":
                case ",":
                  //Wrap up the current string that was being handled
                  //PlayerMessage(buf);
                  if (parsestate == KeyState) {
                      j.e[j.count].key = StripQuotes(buf);
                      parsestate = ValState;
                  } else if (parsestate == ValState) {
                      //j.e[j.count].value[j.e[j.count].valCount]=StripQuotes(buf);
                      j.e[j.count].value[j.e[j.count].valCount]=buf;
                      j.e[j.count].valCount++;
                      parsestate = KeyState;
                      elemDone = True;
                  } else if (parsestate == ArrayState) {
                      //j.e[j.count].value[j.e[j.count].valCount]=StripQuotes(buf);
                      j.e[j.count].value[j.e[j.count].valCount]=buf;
                      j.e[j.count].valCount++;
                  } else if (parsestate == ArrayDoneState){
                      parseState = KeyState;
                  }
                case "{":
                    buf = "";
                    break;
                
                case "}":
                    //PlayerMessage(buf);
                    if (parsestate == ValState) {
                      //j.e[j.count].value[j.e[j.count].valCount]=StripQuotes(buf);
                      j.e[j.count].value[j.e[j.count].valCount]=buf;
                      j.e[j.count].valCount++;
                      parsestate = KeyState;
                      elemDone = True;
                    }
                    msgDone = True;
                    break;
                
                case "]":
                    if (parsestate == ArrayState) {
                        //j.e[j.count].value[j.e[j.count].valCount]=StripQuotes(buf);
                        j.e[j.count].value[j.e[j.count].valCount]=buf;
                        j.e[j.count].valCount++;
                        elemDone = True;
                        parsestate = ArrayDoneState;
                    } else {
                        buf = buf $ c;
                    }
                    break;
                case "[":
                    if (parsestate == ValState){
                        parsestate = ArrayState;
                    } else {
                        buf = buf $ c;
                    }
                    break;
                case Chr(34): //Quotes
                    inQuotes = !inQuotes;
                    break;
                default:
                    //Build up the buffer
                    buf = buf $ c;
                    break;
                
            }
        } else {
            switch(c) {
                case Chr(34): //Quotes
                    if (escape) {
                        escape = False;
                        buf = buf $ JsonGetEscapedChar(c);                       
                    } else {
                        inQuotes = !inQuotes;
                    }
                    break;
                case Chr(92): //Backslash, escape character time
                    if (escape) {
                        //If there has already been one, then we need to turn it into the right char
                        escape = False;
                        buf = buf $ JsonGetEscapedChar(c);
                    } else {
                        escape = True;
                    }
                    break;
                default:
                    //Build up the buffer
                    if (escape) {
                        escape = False;
                        buf = buf $ JsonGetEscapedChar(c);
                    } else {
                        buf = buf $ c;
                    }
                    break;                
            }
        }
        
        if (elemDone) {
          //PlayerMessage("Key: "$j.e[j.count].key$ "   Val: "$j.e[j.count].value[0]);
          j.count++;
          elemDone = False;          
        }
    }
    
    return j;
    
}

function Init( DXRando tdxr, DXRCrowdControl cc, string addr, bool anonymous)
{
    dxr = tdxr;   
    ccModule = cc;
    crowd_control_addr = addr; 
    anon = anonymous;
    
    //Initialize the pending message buffer
    pendingMsg = "";
    
    //Initialize the ticker
    ticker = 0;
    
    lavaTick = 0;


    Resolve(crowd_control_addr);

    reconnectTimer = ReconDefault;
    SetTimer(0.1,True);

}


//Gets called on every level entry
//Some effects need to be reapplied on each level entry (eg. ice physics)
//Make sure to do that here
function InitOnEnter() {
    local inventory anItem;
    
    if (getTimer('cc_MatrixModeTimer') > 0) {
        StartMatrixMode();
    } else {
        StopMatrixMode(True);
    }
    
    dxr.Player.bWarrenEMPField = isTimerActive('cc_EmpTimer');

    if (isTimerActive('cc_SpeedTimer')) {
        dxr.Player.Default.GroundSpeed = DefaultGroundSpeed * retrieveFloatValue('cc_moveSpeedModifier');        
    } else {
        dxr.Player.Default.GroundSpeed = DefaultGroundSpeed;        
    }
    
    if (isTimerActive('cc_lamthrowerTimer')) {
        anItem = dxr.Player.FindInventoryType(class'WeaponFlamethrower');
        if (anItem!=None) {
            MakeLamThrower(anItem);
        }
    } else {
        UndoLamThrowers();        
    }
    
    SetIcePhysics(isTimerActive('cc_iceTimer'));
    
    SetFloatyPhysics(isTimerActive('cc_floatyTimer'));
    
    dxr.Player.bBehindView=isTimerActive('cc_behindTimer');
    
    if (0==retrieveFloatValue('cc_damageMult')) {
        storeFloatValue('cc_damageMult',1.0);
    }
    if (!isTimerActive('cc_DifficultyTimer')) {
        storeFloatValue('cc_damageMult',1.0);
    }
    
    if (isTimerActive('cc_invertMouseTimer')) {
        dxr.Player.bInvertMouse = !dxr.Player.FlagBase.GetBool('cc_InvertMouseDef');
    }
    
    if (isTimerActive('cc_invertMovementTimer')) {
        invertMovementControls();
    }
    
    

}

//Effects should revert to default before exiting a level
//so that they can be cleanly re-applied next time you enter
function CleanupOnExit() {
    StopMatrixMode(True);  //matrix
    dxr.Player.bWarrenEMPField = false;  //emp
    dxr.Player.JumpZ = dxr.Player.Default.JumpZ;  //disable_jump
    dxr.Player.Default.GroundSpeed = DefaultGroundSpeed;  //gotta_go_fast and gotta_go_slow
    UndoLamThrowers(); //lamthrower
    SetIcePhysics(False); //ice_physics
    dxr.Player.bBehindView = False; //third_person
    SetFloatyPhysics(False);
    if (isTimerActive('cc_invertMouseTimer')) {
        dxr.Player.bInvertMouse = dxr.Player.FlagBase.GetBool('cc_InvertMouseDef');
    }

    if (isTimerActive('cc_invertMovementTimer')) {
        invertMovementControls();
    }

}

function StartMatrixMode() {
    if (dxr.Player.Sprite == None)
    {
        dxr.Player.Matrix();
    }
}

function StopMatrixMode(optional bool silent) {
    if (dxr.Player.Sprite!=None) {
        dxr.Player.Matrix();
    }

    if (!silent) {
        PlayerMessage("Your powers fade...");
    }

}


function float retrieveFloatValue(name valName) {
    if( datastorage == None ) datastorage = class'DataStorage'.static.GetObj(dxr.Player);
    return float(datastorage.GetConfigKey(valName));
}

function storeFloatValue(name valName, float val) {
    if( datastorage == None ) datastorage = class'DataStorage'.static.GetObj(dxr.Player);
    datastorage.SetConfig(valName, val, 3600*12);

}


function int getDefaultTimerTimeByName(name timerName) {
    switch(timerName) {
        case 'cc_MatrixModeTimer':
            return MatrixTimeDefault;
        case 'cc_EmpTimer':
            return EmpDefault;
        case 'cc_JumpTimer':
            return JumpTimeDefault;
        case 'cc_SpeedTimer':
            return SpeedTimeDefault;
        case 'cc_lamthrowerTimer':
            return LamThrowerTimeDefault;
        case 'cc_iceTimer':
            return IceTimeDefault;
        case 'cc_behindTimer':
            return BehindTimeDefault;
        case 'cc_DifficultyTimer':
            return DifficultyTimeDefault;
        case 'cc_floatyTimer':
            return FloatyTimeDefault;
        case 'cc_floorLavaTimer':
            return FloorLavaTimeDefault;
        case 'cc_invertMouseTimer':
            return InvertMouseTimeDefault;
        case 'cc_invertMovementTimer':
            return InvertMovementTimeDefault;
        
        default:
            PlayerMessage("Unknown timer name "$timerName);
            return 0;
    }
}

function string getTimerLabelByName(name timerName) {
    local float val;
    
    switch(timerName) {
        case 'cc_MatrixModeTimer':
            return "Matrix";
        case 'cc_EmpTimer':
            return "EMP Field";
        case 'cc_JumpTimer':
            return "No Jump";
        case 'cc_SpeedTimer':
            val = retrieveFloatValue('cc_moveSpeedModifier');
            if (val == MoveSpeedMultiplier) {
                return "Speed";
            } else if (val == MoveSpeedDivisor) {
                return "Slow";
            }
            return "??? Speed";
        case 'cc_lamthrowerTimer':
            return "LAMThrower";
        case 'cc_iceTimer':
            return "Ice Phys";
        case 'cc_behindTimer':
            return "3rd Pers";
        case 'cc_DifficultyTimer':
            val = retrieveFloatValue('cc_damageMult');
            if (val == 2.0) {
                return "2x Dmg";
            } else if (val == 0.5) {
                return "1/2 Dmg";            
            }
            return "??? Damage";
        case 'cc_floatyTimer':
            return "Float";
        case 'cc_floorLavaTimer':
            return "Lava";
        case 'cc_invertMouseTimer':
            return "Inv Mouse";
        case 'cc_invertMovementTimer':
            return "Inv Move";
        
        default:
            PlayerMessage("Unknown timer name "$timerName);
            return "???";
    }
}

function removeTimerDisplay(DXRandoCrowdControlTimer tDisplay) {
    local int i;
    
    //PlayerMessage("Removing display");
    
    for (i=0;i < 32; i++) {
        if (timerDisplays[i] == tDisplay) {
            //timerDisplays[i].Destroy();
            timerDisplays[i] = None;
        }
    }
}

function addTimerDisplay(name timerName, int time) {
    local DXRandoCrowdControlTimer timer;
    local int i;
    
    //PlayerMessage("Adding display");
    
    timer = Spawn(class'DXRandoCrowdControlTimer', dxr.Player,,dxr.Player.Location);
    timer.initTimer(self,timerName,time,getTimerLabelByName(timerName));
    timer.Activate();
    
    //Find a spot to keep track of the timer
    
    for (i = 0; i < 32; i++) {
        if (timerDisplays[i] == None) {
            timerDisplays[i] = timer;
            return;
        }
    }
    PlayerMessage("Couldn't find location to track Crowd Control timer!");
}

function bool checkForTimerDisplay(name timerName) {
    local int i;
    
    for (i = 0; i < 32; i++) {
        if (timerDisplays[i].GetTimerName() == timerName) {
            return True;
        }
    }
    
    return False;
}

function int getTimer(name timerName) {
    if( datastorage == None ) datastorage = class'DataStorage'.static.GetObj(dxr.Player);
    return int(datastorage.GetConfigKey(timerName));
}

function setTimerFlag(name timerName, int time, bool newTimer) {
    local int expiration;
    if( datastorage == None ) datastorage = class'DataStorage'.static.GetObj(dxr.Player);
    if( time == 0 ) expiration = 1;
    else expiration = 3600*12;
    datastorage.SetConfig(timerName, time, expiration);
    if (newTimer) { 
        addTimerDisplay(timerName,time);
    } else {
        //This is basically just for if you reload a game, or change maps
        if (checkForTimerDisplay(timerName) == False) {
            addTimerDisplay(timerName,getDefaultTimerTimeByName(timerName)); 
        }
    }
}

function bool isTimerActive(name timerName) {
    return (getTimer(timerName) > 0);
}

//Timers only decrement while playing
function bool decrementTimer(name timerName) {
    local int time;
    time = getTimer(timerName);
    if (time>0 && InGame()) {
        time -= 1;
        setTimerFlag(timerName,time,False);
        
        return (time == 0);
    }
    return false;
}

function startNewTimer(name timerName) {
    setTimerFlag(timerName,getDefaultTimerTimeByName(timerName),True);

}

function Timer() {
    
    ticker++;
    if (IsConnected()) {
        ManualReceiveBinary();
    }

    //Lava floor logic
    if (isTimerActive('cc_floorLavaTimer') && InGame()){
        floorIsLava();
    }


    if (ticker%10 != 0) {
        return;
    }
    //Everything below here runs once a second

    if (!IsConnected()) {
        reconnectTimer-=1;
        if (reconnectTimer <= 0){
            Resolve(crowd_control_addr);
        }
    } 

    //Matrix Mode Timer
    if (decrementTimer('cc_MatrixModeTimer')) {
        StopMatrixMode();
    }

    //EMP Field timer
    if (decrementTimer('cc_EmpTimer')) {
            dxr.Player.bWarrenEMPField = false;
            PlayerMessage("EMP Field has disappeared...");        
    }

    if (isTimerActive('cc_JumpTimer')) {
        dxr.Player.JumpZ = 0;        
    }
    if (decrementTimer('cc_JumpTimer')) {
        dxr.Player.JumpZ = dxr.Player.Default.JumpZ;
        PlayerMessage("Your knees feel fine again.");
    }

    if (isTimerActive('cc_SpeedTimer')) {
        dxr.Player.Default.GroundSpeed = DefaultGroundSpeed * retrieveFloatValue('cc_moveSpeedModifier');        
    }
    if (decrementTimer('cc_SpeedTimer')) {
        dxr.Player.Default.GroundSpeed = DefaultGroundSpeed;
        PlayerMessage("Back to normal speed!");
    }

    if (decrementTimer('cc_lamthrowerTimer')) {
        UndoLamThrowers();
        PlayerMessage("Your flamethrower is boring again");

    }
    
    if (decrementTimer('cc_iceTimer')) {
        SetIcePhysics(False);
        PlayerMessage("The ground thaws");
    }
    
    if (decrementTimer('cc_behindTimer')) {
        dxr.Player.bBehindView=False;
        PlayerMessage("You re-enter your body");
    }
    
    if (decrementTimer('cc_DifficultyTimer')){
        storeFloatValue('cc_damageMult',1.0);        
        PlayerMessage("Your body returns to its normal toughness");
    }
    
    if (decrementTimer('cc_floatyTimer')) {
        SetFloatyPhysics(False);
        PlayerMessage("You feel weighed down again");
    }
    
    if (decrementTimer('cc_floorLavaTimer')) {
        PlayerMessage("The floor returns to normal temperatures");
    }
    
    if (decrementTimer('cc_invertMouseTimer')) {
        PlayerMessage("Your mouse controls return to normal");
        dxr.Player.bInvertMouse = dxr.Player.FlagBase.GetBool('cc_InvertMouseDef');
    }

    if (decrementTimer('cc_invertMovementTimer')) {
        PlayerMessage("Your movement controls return to normal");
        invertMovementControls();
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

function class<Augmentation> getAugClass(string type) {
    return class<Augmentation>(ccModule.GetClassFromString(type, class'Augmentation'));
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

function int AddCredits(int amount,string viewer) {
    //Reject requests to remove credits if the player doesn't have any
    if (dxr.Player.Credits == 0  && amount<0) {
        return Failed;
    }
    
    dxr.Player.Credits += amount;
    
    if (amount>0) {
        PlayerMessage(viewer@"gave you "$amount$" credits!");
    } else {
        PlayerMessage(viewer@"took away "$(-amount)$" credits!");        
    }
    
    if (dxr.Player.Credits < 0) {
        dxr.Player.Credits = 0;
    }
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


function float GetDefaultZoneFriction(ZoneInfo z)
{
    local int i;
    for(i=0; i<ArrayCount(zone_frictions); i++) {
        if( z.name == zone_frictions[i].zonename )
            return zone_frictions[i].friction;
    }
    return NormalFriction;
}

function SaveDefaultZoneFriction(ZoneInfo z)
{
    local int i;
    if( z.ZoneGroundFriction ~= NormalFriction ) return;
    for(i=0; i<ArrayCount(zone_frictions); i++) {
        if( zone_frictions[i].zonename == '' || z.name == zone_frictions[i].zonename ) {
            zone_frictions[i].zonename = z.name;
            zone_frictions[i].friction = z.ZoneGroundFriction;
            return;
        }
    }
}

function vector GetDefaultZoneGravity(ZoneInfo z)
{
    local int i;
    for(i=0; i<ArrayCount(zone_gravities); i++) {
        if( z.name == zone_gravities[i].zonename )
            return zone_gravities[i].gravity;
        if( zone_gravities[i].zonename == '' )
            break;
    }
    return NormalGravity;
}

function SaveDefaultZoneGravity(ZoneInfo z)
{
    local int i;
    if( z.ZoneGravity.X ~= NormalGravity.X && z.ZoneGravity.Y ~= NormalGravity.Y && z.ZoneGravity.Z ~= NormalGravity.Z ) return;
    for(i=0; i<ArrayCount(zone_gravities); i++) {
        if( z.name == zone_gravities[i].zonename )
            return;
        if( zone_gravities[i].zonename == '' ) {
            zone_gravities[i].zonename = z.name;
            zone_gravities[i].gravity = z.ZoneGravity;
            return;
        }
    }
}

function SetFloatyPhysics(bool enabled) {
    local ZoneInfo Z;
    
    local Actor A;
    local bool apply;
    
    ForEach AllActors(class'ZoneInfo', Z)
    {
        log("SetFloatyPhysics "$Z$" gravity: "$Z.ZoneGravity);
        if (enabled && Z.ZoneGravity != FloatGrav ) {
            SaveDefaultZoneGravity(Z);
            Z.ZoneGravity = FloatGrav;
        }
        else if ( (!enabled) && Z.ZoneGravity == FloatGrav ) {
            Z.ZoneGravity = GetDefaultZoneGravity(Z);
        }
    }
    
    if (enabled){
        //Get everything floating immediately
        ForEach AllActors(class'Actor',A)
        {
            apply = False;
            if (A.isa('ScriptedPawn')){
                apply = (A.GetStateName() != 'Patrolling' &&
                         ScriptedPawn(A).Orders != 'Sitting');
            } else if (A.isa('PlayerPawn')) {
                apply = True;
            } else if (A.isa('Decoration')) {
                apply = ((A.Base!=None && 
                          A.Physics == PHYS_None && 
                          A.bStatic == False &&
                          Decoration(A).bPushable == True) || A.isa('Carcass'));
            } else if (A.isa('Inventory')) {
                apply = (Pawn(A.Owner) == None);
            }
            
            if (apply) {
                A.Velocity.Z+=Rand(10)+1;
                A.SetPhysics(PHYS_Falling);               
            }
        }    
    }
}

function SetMoonPhysics(bool enabled) {
    local ZoneInfo Z;
    ForEach AllActors(class'ZoneInfo', Z)
    {
        log("SetFloatyPhysics "$Z$" gravity: "$Z.ZoneGravity);
        if (enabled && Z.ZoneGravity != MoonGrav ) {
            SaveDefaultZoneGravity(Z);
            Z.ZoneGravity = MoonGrav;
        }
        else if ( (!enabled) && Z.ZoneGravity == MoonGrav ) {
            Z.ZoneGravity = GetDefaultZoneGravity(Z);
        }
    }
}

function SetIcePhysics(bool enabled) {
    local ZoneInfo Z;
    ForEach AllActors(class'ZoneInfo', Z) {
        if (enabled && Z.ZoneGroundFriction != IceFriction ) {
            SaveDefaultZoneFriction(Z);
            Z.ZoneGroundFriction = IceFriction;
        }
        else if ( (!enabled) && Z.ZoneGroundFriction == IceFriction ) {
            Z.ZoneGroundFriction = GetDefaultZoneFriction(Z);
        }
    }
}


//Returns true when you aren't in a menu, or in the intro, etc.
function bool InGame() {
    if (None == DeusExRootWindow(dxr.Player.rootWindow)) {
        return False;
    }
    
    if (None == DeusExRootWindow(dxr.Player.rootWindow).hud) {
        return False;
    }
    
    if (!DeusExRootWindow(dxr.Player.rootWindow).hud.isVisible()){
        return False;
    }
    
    return True;
}


function int doCrowdControlEvent(string code, string param[5], string viewer, int type) {
    local int i;

    switch(code) {
        case "poison":
            if (!InGame()) {
                return TempFail;
            }
        
            dxr.Player.StartPoison(dxr.Player,5);
            PlayerMessage(viewer@"poisoned you!");
            break;

        case "kill":
            dxr.Player.Died(dxr.Player,'CrowdControl',dxr.Player.Location);
            PlayerMessage(viewer@"set off your killswitch!");
            dxr.Player.MultiplayerDeathMsg(dxr.Player,False,True,viewer,"triggering your kill switch");
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
            dxr.Player.HealPlayer(Int(param[0]),False);
            PlayerMessage(viewer@"gave you "$param[0]$" health!");
            break;

        case "set_fire":
            dxr.Player.CatchFire(dxr.Player);
            PlayerMessage(viewer@"set you on fire!");
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
            startnewTimer('cc_JumpTimer');
            PlayerMessage(viewer@"made your knees lock up.");
            break;

        case "gotta_go_fast":
            if (DefaultGroundSpeed != dxr.Player.Default.GroundSpeed) {
                return TempFail;
            }
            storeFloatValue('cc_moveSpeedModifier',MoveSpeedMultiplier);
            dxr.Player.Default.GroundSpeed = DefaultGroundSpeed * moveSpeedMultiplier;
            startNewTimer('cc_SpeedTimer');
            PlayerMessage(viewer@"made you fast like Sonic!");
            break;

        case "gotta_go_slow":
            if (DefaultGroundSpeed != dxr.Player.Default.GroundSpeed) {
                return TempFail;
            }
            storeFloatValue('cc_moveSpeedModifier',MoveSpeedDivisor);
            dxr.Player.Default.GroundSpeed = DefaultGroundSpeed * moveSpeedDivisor;
            startNewTimer('cc_SpeedTimer');
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
            if (dxr.Player.InHand == None) {
                return TempFail;
            }
            
            if (canDropItem() == False) {
                return TempFail;
            }
            
            if (dxr.Player.DropItem() == False) {
                return TempFail;
            }
            PlayerMessage(viewer@"made you fumble your item");
            break;

        case "emp_field":
            dxr.Player.bWarrenEMPField = true;
            startNewTimer('cc_EmpTimer');
            PlayerMessage(viewer@"made electronics allergic to you");
            break;

        case "matrix":
            if (dxr.Player.Sprite!=None) {
                //Matrix Mode already enabled
                return TempFail;
            }
            StartMatrixMode();
            startNewTimer('cc_MatrixModeTimer');
            PlayerMessage(viewer@"thinks you are The One...");
            break;
            
        case "third_person":
            if (isTimerActive('cc_behindTimer')) {
                return TempFail;
            }
            dxr.Player.bBehindView=True;
            startNewTimer('cc_behindTimer');
            PlayerMessage(viewer@"gave you an out of body experience");
            break;

        case "give_energy":
            
            if (dxr.Player.Energy == dxr.Player.EnergyMax) {
                return TempFail;
            }
            //Copied from BioelectricCell

            //PlayerMessage("Recharged 10 points");
            dxr.Player.PlaySound(sound'BioElectricHiss', SLOT_None,,, 256);

            dxr.Player.Energy += Int(param[0]);
            if (dxr.Player.Energy > dxr.Player.EnergyMax)
                dxr.Player.Energy = dxr.Player.EnergyMax;

            PlayerMessage(viewer@"gave you "$param[0]$" energy!");
            break;

        case "give_skillpoints":
            i = Int(param[0])*100;
            PlayerMessage(viewer@"gave you "$i$" skill points");
            dxr.Player.SkillPointsAdd(i);
            break;

        case "remove_skillpoints":
            i = Int(param[0])*100;
            PlayerMessage(viewer@"took away "$i$" skill points");
            SkillPointsRemove(i);
            break;
            
        case "add_credits":
            return AddCredits(Int(param[0])*100,viewer);
            break;
        case "remove_credits":
            return AddCredits(-Int(param[0])*100,viewer);
            break;

        case "lamthrower":
            return GiveLamThrower(viewer);
        
        case "dmg_double":
            if (isTimerActive('cc_DifficultyTimer')) {
                return TempFail;
            }
            storeFloatValue('cc_damageMult',2.0);
           
            PlayerMessage(viewer@"made your body extra squishy");
            startNewTimer('cc_DifficultyTimer');
            break;
        case "dmg_half":
            if (isTimerActive('cc_DifficultyTimer')) {
                return TempFail;
            }
            storeFloatValue('cc_damageMult',0.5);
            PlayerMessage(viewer@"made your body extra tough!");
            startNewTimer('cc_DifficultyTimer');
            break;
        
        case "ice_physics":
            if (isTimerActive('cc_iceTimer')) {
                return TempFail;
            }
            PlayerMessage(viewer@"made the ground freeze!");
            SetIcePhysics(True);
            startNewTimer('cc_iceTimer');

            break;      
        
        case "ask_a_question":
            if (!InGame()) {
                return TempFail;
            }
            AskRandomQuestion(viewer);
            break;

        case "nudge":
            if (!InGame()) {
                return TempFail;
            }

            doNudge(viewer);
            break;
            
        case "swap_player_position":
            if (!InGame()) {
                return TempFail;
            }
            if (swapPlayer(viewer) == false) {
                return Failed;
            }
            break;
            
        case "floaty_physics":
            if (isTimerActive('cc_floatyTimer')) {
                return TempFail;
            }
            PlayerMessage(viewer@"made you feel light as a feather");
            SetFloatyPhysics(True);
            startNewTimer('cc_floatyTimer');

            break;   

        case "floor_is_lava":
            if (!InGame()) {
                return TempFail;
            }
            if (isTimerActive('cc_floorLavaTimer')){
                return TempFail;
            }
            PlayerMessage(viewer@"turned the floor into lava!");
            lavaTick = 0;
            startNewTimer('cc_floorLavaTimer');
            
            break;
            
        case "invert_mouse":
            if (!InGame()) {
                return TempFail;
            }
            if (isTimerActive('cc_invertMouseTimer')){
                return TempFail;
            }
            PlayerMessage(viewer@"inverted your mouse!");
            dxr.Player.FlagBase.SetBool('cc_InvertMouseDef',dxr.Player.bInvertMouse);

            dxr.Player.bInvertMouse = !dxr.Player.bInvertMouse;
            startNewTimer('cc_invertMouseTimer');

            break;
            
        case "invert_movement":
            if (!InGame()) {
                return TempFail;
            }
            if (isTimerActive('cc_invertMovementTimer')){
                return TempFail;
            }
            PlayerMessage(viewer@"inverted your movement controls!");
            
            invertMovementControls();

            startNewTimer('cc_invertMovementTimer');
            break;

        default:
            return doCrowdControlEventWithPrefix(code, param, viewer, type);
    }

    return Success;
}

function int doCrowdControlEventWithPrefix(string code, string param[5], string viewer, int type) {
    local string words[8];

    SplitString(code, "_", words);

    switch(words[0]) {
        case "drop":
            return DropProjectile(viewer, words[1], Int(param[0]));
        case "give":
            return GiveItem(viewer, words[1], Int(param[0]));
        case "add":
            return GiveAug(getAugClass(words[1]),viewer);
        case "rem":
            return RemoveAug(getAugClass(words[1]),viewer);
        default:
            err("Unknown effect: "$code);
            return NotAvail;
    }

    return Success;
}

function int GiveLamThrower(string viewer)
{
    local Inventory anItem;

    if (isTimerActive('cc_lamthrowerTimer')) {
        return TempFail;
    }
    
    anItem = dxr.Player.FindInventoryType(class'WeaponFlamethrower');
    if (anItem==None) {
        return TempFail;
    }

    MakeLamThrower(anItem);
    setTimerFlag('cc_lamthrowerTimer',LamThrowerTimeDefault,True);
    PlayerMessage(viewer@"turned your flamethrower into a LAM Thrower!");
    return Success;
}

function invertMovementControls() {
    local string fwdInputs[5];
    local string backInputs[5];
    local string leftInputs[5];
    local string rightInputs[5];
    
    local int numFwd;
    local int numBack;
    local int numLeft;
    local int numRight;
    
    local string KeyName;
    local string Alias;
    
    local int i;
    
    for (i=0;i<255;i++) {
        KeyName = dxr.Player.ConsoleCommand("KEYNAME "$i);
        if (KeyName!="") {
            Alias = dxr.Player.ConsoleCommand("KEYBINDING "$KeyName);
            //PlayerMessage("Alias is "$Alias);
            switch(Alias){
                case "MoveForward":
                    fwdInputs[numFwd] = KeyName;
                    numFwd++;
                    break;
                case "MoveBackward":
                    backInputs[numBack] = KeyName;
                    numBack++;
                    break;
                case "StrafeLeft":
                    leftInputs[numLeft] = KeyName;
                    numLeft++;
                    break;
                case "StrafeRight":
                    rightInputs[numRight] = KeyName;
                    numRight++;
                    break;
            }
        }
    }
    
    for (i=0;i<numFwd;i++){
        dxr.Player.ConsoleCommand("SET InputExt "$fwdInputs[i]$" MoveBackward");
    }
    for (i=0;i<numBack;i++){
        dxr.Player.ConsoleCommand("SET InputExt "$backInputs[i]$" MoveForward");
    }
    for (i=0;i<numRight;i++){
        dxr.Player.ConsoleCommand("SET InputExt "$rightInputs[i]$" StrafeLeft");
    }
    for (i=0;i<numLeft;i++){
        dxr.Player.ConsoleCommand("SET InputExt "$leftInputs[i]$" StrafeRight");
    }    
    
}

function floorIsLava() {
    local vector v;
    local vector loc;
    loc.X = dxr.Player.Location.X;
    loc.Y = dxr.Player.Location.Y;
    loc.Z = dxr.Player.Location.Z - 1;
    if ((dxr.Player.Base.IsA('LevelInfo') ||
         dxr.Player.Base.IsA('Mover')) &&
         Human(dxr.Player).bOnLadder==False)        {
        lavaTick++;   
        //PlayerMessage("Standing on Lava! "$lavaTick);        
    } else {
        lavaTick = 0;
        //PlayerMessage("Not Lava "$dxr.Player.Base);
        return;
    }
    
    if ((lavaTick % 10)==0) { //If you stand on lava for 1 second
        dxr.Player.TakeDamage(10,dxr.Player,loc,v,'Burned');
    }
    
    if ((lavaTick % 50)==0) { //if you stand in lava for 5 seconds
        dxr.Player.CatchFire(dxr.Player);
    }
}

function int GiveItem(string viewer, string type, optional int amount) {
    local int i;
    local class<Inventory> itemclass;
    local string outMsg;
    local Inventory item;
    
    if( amount < 1 ) amount = 1;
    
    itemclass = class<Inventory>(ccModule.GetClassFromString(type,class'Inventory'));
    
    if (itemclass == None) {
        return NotAvail;
    }
    
    for (i=0;i<amount;i++) {
        item = class'DXRActorsBase'.static.GiveItem(dxr.Player, itemclass);
        if( item == None ) return Failed;
    }

    outMsg = viewer@"gave you";
    if( amount > 1 && DeusExAmmo(item) != None ) {
        outMsg = outMsg @amount@"cases of"@item.Default.ItemName;
    }
    else if( DeusExAmmo(item) != None ) {
        outMsg = outMsg @"a case of"@item.Default.ItemName;
    }
    else if( amount > 1 ) {
        outMsg = outMsg @ amount @ item.Default.ItemName $ "s";
    } else {
        outMsg = outMsg @ item.Default.ItemArticle @ item.Default.ItemName;
    }

    PlayerMessage(outMsg);
    return Success;
}

function int DropProjectile(string viewer, string type, optional int amount)
{
    local class<DeusExProjectile> c;
    local DeusExProjectile p;
    if( amount < 1 ) amount = 1;

    //Don't drop grenades if you're in the menu
    if (!InGame()) {
        return TempFail;
    }

    //Don't drop grenades if you're in a conversation - It screws things up
    if (dxr.Player.InConversation()) {
        return TempFail;
    }

    c = class<DeusExProjectile>(ccModule.GetClassFromString(type, class'DeusExProjectile'));
    if( c == None ) return NotAvail;
    p = Spawn( c, dxr.Player,,dxr.Player.Location);
    if( p == None ) return Failed;
    PlayerMessage(viewer@"dropped "$ p.ItemArticle @ p.ItemName $ " at your feet!");
    p.Velocity.X=0;
    p.Velocity.Y=0;
    p.Velocity.Z=0;
    return Success;
}

function ScriptedPawn findOtherHuman() {
    local int num;
    local ScriptedPawn p;
    local ScriptedPawn humans[512];
    
    num = 0;
    
    foreach AllActors(class'ScriptedPawn',p) {
        if (class'DXRActorsBase'.static.IsHuman(p) && p!=dxr.Player && !p.bHidden && !p.bStatic && p.bInWorld && p.Orders!='Sitting') {
            humans[num++] = p;
        }
    }

    if( num == 0 ) return None;
    return humans[ Rand(num) ];
}

function bool swapPlayer(string viewer) {
    local ScriptedPawn a;
    
    a = findOtherHuman();
    
    if (a == None) {
        return false;
    }
    
    ccModule.Swap(dxr.Player,a);
    dxr.Player.ViewRotation = dxr.Player.Rotation;
    PlayerMessage(viewer@"thought you would look better if you were where"@a.FamiliarName@"was");
    
    return true;
}

function doNudge(string viewer) {
    local Rotator r;
    local vector newAccel;
    
    newAccel.X = Rand(201)-100;
    newAccel.Y = Rand(201)-100;
    //newAccel.Z = Rand(31);
    
    //Not super happy with how this looks,
    //Since you sort of just teleport to the new position
    dxr.Player.MoveSmooth(newAccel);
    
    //Play an oof sound
    dxr.Player.PlaySound(Sound'DeusExSounds.Player.MalePainSmall');
    
    PlayerMessage(viewer@"nudged you a little bit");

}

function AskRandomQuestion(String viewer) {
    
    local string question;
    local string answers[3];
    local int numAnswers;
    
    ccModule.getRandomQuestion(question,numAnswers,answers[0],answers[1],answers[2]);
    
    ccModule.CreateCustomMessageBox(viewer$" asks...",question,numAnswers,answers,ccModule,1,True);
    
}

function bool canDropItem() {
	local Vector X, Y, Z, dropVect;
	local Inventory item;
    
    item = dxr.Player.InHand;
    
    if (item == None) {
        return False;
    }
    
	GetAxes(dxr.Player.Rotation, X, Y, Z);
	dropVect = dxr.Player.Location + (dxr.Player.CollisionRadius + 2*item.CollisionRadius) * X;
	dropVect.Z += dxr.Player.BaseEyeHeight;
    
	// check to see if we're blocked by terrain
	if (!dxr.Player.FastTrace(dropVect))
	{
		return False;
	}
    
    return True;

}


function handleMessage( string msg) {
  
    local int id,type;
    local string code,viewer;
    local string param[5];
    
    local int result;
    
    local JsonMsg jmsg;
    local string val;
    local int i,j;

    if (isCrowdControl(msg)) {
        jmsg=ParseJson(msg);
        
        for (i=0;i<jmsg.count;i++) {
            if (jmsg.e[i].valCount>0) {
                val = jmsg.e[i].value[0];
                //PlayerMessage("Key: "$jmsg.e[i].key);
                switch (jmsg.e[i].key) {
                    case "code":
                        code = val;
                        break;
                    case "viewer":
                        viewer = val;
                        break;
                    case "id":
                        id = Int(val);
                        break;
                    case "type":
                        type = Int(val);
                        break;
                    case "parameters":
                        for (j=0;j<5;j++) {
                            param[j] = jmsg.e[i].value[j];
                        }
                        break;
                }
            }
        }
        
        //Streamers may not want names to show up in game
        //so that they can avoid troll names, etc
        if (anon) {
            viewer = "Crowd Control";
        }
        result = doCrowdControlEvent(code,param,viewer,type);
        
        if (result == Success) {
            ccModule.IncHandledEffects();
        }
        
        sendReply(id,result);
        
    } else {
        err("Got a weird message: "$msg);
    }

}

//I cannot believe I had to manually write my own version of ReceivedBinary
function ManualReceiveBinary() {
    local byte B[255]; //I have to use a 255 length array even if I only want to read 1
    local int count,i;
    //PlayerMessage("Manually reading, have "$DataPending$" bytes pending");
    
    if (DataPending!=0) {
        count = ReadBinary(255,B);
        for (i = 0; i < count; i++) {
            if (B[i] == 0) {
                if (Len(pendingMsg)>0){
                    //PlayerMessage(pendingMsg);
                    handleMessage(pendingMsg);
                }
                pendingMsg="";
            } else {
                pendingMsg = pendingMsg $ Chr(B[i]);
                //PlayerMessage("ReceivedBinary: " $ B[i]);
            }
        }
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


//This seems to just receive crazy garbage and is completely broken.
event ReceivedBinary(int count, byte B[255]) {
    local int i;
    for (i = 0; i < count; i++) {
        //log("Got character val "$i+1$" = "$B[i]);
        if (B[i] == 0) {
            //handleMessage(pendingMsg);
            if (Len(pendingMsg)>0){
            //PlayerMessage("got message (maybe): "$pendingMsg);
            }
            pendingMsg="";
        } else {
            pendingMsg = pendingMsg $ Chr(B[i]);
            //PlayerMessage("ReceivedBinary: " $ B[i]);
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

    //Using manual binary reading, which is handled by ManualReceiveBinary()
    //This means that we can handle if multiple crowd control messages come in
    //between reads.
    LinkMode=MODE_Binary;
    ReceiveMode = RMODE_Manual;

}
function ResolveFailed()
{
    err("Could not resolve Crowd Control address");
    reconnectTimer = ReconDefault;
}

function PlayerMessage(string msg)
{
    log(Self$": "$msg);
    class'DXRTelemetry'.static.SendLog(dxr, Self, "INFO", msg);
    dxr.Player.ClientMessage(msg, 'CrowdControl', true);
}

function err(string msg)
{
    log(Self$": ERROR: "$msg);
    class'DXRTelemetry'.static.SendLog(dxr, Self, "ERROR", msg);
    dxr.Player.ClientMessage(msg, 'ERROR', true);
}

function info(string msg)
{
    log(Self$": INFO: "$msg);
    class'DXRTelemetry'.static.SendLog(dxr, Self, "INFO", msg);
}

function SplitString(string src, string divider, out string parts[8])
{
    local int i, c;

    parts[0] = src;
    for(i=0; i+1<ArrayCount(parts); i++) {
        c = InStr(parts[i], divider);
        if( c == -1 ) {
            return;
        }
        parts[i+1] = Mid(parts[i], c+1);
        parts[i] = Left(parts[i], c);
    }
}

function RunTests(DXRCrowdControl m)
{
    local int i;
    local string msg;
    local string params[5];
    local string words[8];

    SplitString("add_aug_aqualung", "_", words);
    m.teststring(words[0], "add", "SplitString");
    m.teststring(words[1], "aug", "SplitString");
    m.teststring(words[2], "aqualung", "SplitString");
    m.teststring(words[3], "", "SplitString");

    msg="";
    m.testbool( isCrowdControl(msg), false, "isCrowdControl "$msg);

    msg="{}";
    m.testbool( isCrowdControl(msg), false, "isCrowdControl "$msg);

    TestMsg(m, 123, 1, "kill", "die4ever", params);
    TestMsg(m, 123, 1, "test with spaces", "die4ever", params);
    TestMsg(m, 123, 1, "test:with:colons", "die4ever", params);
    TestMsg(m, 123, 1, "test,with,commas", "die4ever", params);
    params[0] = "parameter test";
    TestMsg(m, 123, 1, "kill", "die4ever", params);
    params[0] = "g_scrambler";
    TestMsg(m, 123, 1, "drop_grenade", "die4ever", params);
    params[0] = "g_scrambler";
    params[1] = "10";
    TestMsg(m, 123, 1, "drop_grenade", "die4ever", params);
    
    //Need to do more work to validate escaped characters
    //TestMsg(m, 123, 1, "test\\\\with\\\\escaped\\\\backslashes", "die4ever", ""); //Note that we have to double escape so that the end result is a single escaped backslash
}

function TestMsg(DXRCrowdControl m, int id, int type, string code, string viewer, string params[5])
{
    local int i, p, matches, num_params;
    local string msg, val, params_string;
    local JsonMsg jmsg;

    for(i=0; i < ArrayCount(params); i++) {
        if( params[i] != "" ) num_params++;
    }

    if( num_params > 1 ) {
        params_string = "[";
        for(i=0; i < ArrayCount(params); i++) {
            if( params[i] != "" )
                params_string = params_string $ params[i] $ ",";
        }
        params_string = Left(params_string, Len(params_string)-1);//trim trailing comma
        params_string = params_string $ "]";
    }
    else if ( num_params <= 1 )
        params_string = "\""$params[0]$"\"";

    msg="{\"id\":\""$id$"\",\"code\":\""$code$"\",\"viewer\":\""$viewer$"\",\"type\":\""$type$"\",\"parameters\":"$params_string$"}";

    m.testbool( isCrowdControl(msg), true, "isCrowdControl: "$msg);

    jmsg=ParseJson(msg);
    for (i=0;i<jmsg.count;i++) {
        if (jmsg.e[i].valCount>0) {
            val = jmsg.e[i].value[0];
            switch (jmsg.e[i].key) {
                case "code":
                    m.teststring(val, code, "code");
                    matches++;
                    break;
                case "viewer":
                    m.teststring(val, viewer, "viewer");
                    matches++;
                    break;
                case "id":
                    m.testint(Int(val), id, "id");
                    matches++;
                    break;
                case "type":
                    m.testint(Int(val), type, "type");
                    matches++;
                    break;
                case "parameters":
                    for(p=0; p<ArrayCount(params); p++) {
                        m.teststring(jmsg.e[i].value[p], params[p], "param "$p);
                    }
                    matches++;
                    break;
            }
        }
    }

    m.testint(matches, 5, "5 matches for msg: "$msg);
}

defaultproperties
{
    NormalGravity=vect(0,0,-950)
    FloatGrav=vect(0,0,0.15)
    MoonGrav=vect(0,0,-300)
}
