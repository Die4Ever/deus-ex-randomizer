Class DXRCrowdControlEffects extends Info;

var DXRandoCrowdControlLink ccLink;

var DataStorage datastorage;
var transient DXRando dxr;

const Success = 0;
const Failed = 1;
const NotAvail = 2;
const TempFail = 3;

var int lavaTick;

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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                                  CROWD CONTROL FRAMEWORK                                                 ////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function Init(DXRandoCrowdControlLink crowd_control_link, DXRando tdxr)
{
    ccLink = crowd_control_link;
    dxr = tdxr;
    
    lavaTick = 0;
}



function PeriodicUpdates()
{
    //Matrix Mode Timer
    if (decrementTimer('cc_MatrixModeTimer')) {
        StopMatrixMode();
    }

    //EMP Field timer
    if (decrementTimer('cc_EmpTimer')) {
            player().bWarrenEMPField = false;
            PlayerMessage("EMP Field has disappeared...");        
    }

    if (isTimerActive('cc_JumpTimer')) {
        player().JumpZ = 0;        
    }
    if (decrementTimer('cc_JumpTimer')) {
        player().JumpZ = player().Default.JumpZ;
        PlayerMessage("Your knees feel fine again.");
    }

    if (isTimerActive('cc_SpeedTimer')) {
        player().Default.GroundSpeed = DefaultGroundSpeed * retrieveFloatValue('cc_moveSpeedModifier');        
    }
    if (decrementTimer('cc_SpeedTimer')) {
        player().Default.GroundSpeed = DefaultGroundSpeed;
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
        player().bBehindView=False;
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
        player().bInvertMouse = dxr.flagbase.GetBool('cc_InvertMouseDef');
    }

    if (decrementTimer('cc_invertMovementTimer')) {
        PlayerMessage("Your movement controls return to normal");
        invertMovementControls();
    }

}

function ContinuousUpdates()
{
    //Lava floor logic
    if (isTimerActive('cc_floorLavaTimer') && InGame()){
        floorIsLava();
    }

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
    
    player().bWarrenEMPField = isTimerActive('cc_EmpTimer');

    if (isTimerActive('cc_SpeedTimer')) {
        player().Default.GroundSpeed = DefaultGroundSpeed * retrieveFloatValue('cc_moveSpeedModifier');        
    } else {
        player().Default.GroundSpeed = DefaultGroundSpeed;        
    }
    
    if (isTimerActive('cc_lamthrowerTimer')) {
        anItem = player().FindInventoryType(class'WeaponFlamethrower');
        if (anItem!=None) {
            MakeLamThrower(anItem);
        }
    } else {
        UndoLamThrowers();        
    }
    
    SetIcePhysics(isTimerActive('cc_iceTimer'));
    
    SetFloatyPhysics(isTimerActive('cc_floatyTimer'));
    
    player().bBehindView=isTimerActive('cc_behindTimer');
    
    if (0==retrieveFloatValue('cc_damageMult')) {
        storeFloatValue('cc_damageMult',1.0);
    }
    if (!isTimerActive('cc_DifficultyTimer')) {
        storeFloatValue('cc_damageMult',1.0);
    }
    
    if (isTimerActive('cc_invertMouseTimer')) {
        player().bInvertMouse = !dxr.flagbase.GetBool('cc_InvertMouseDef');
    }
    
    if (isTimerActive('cc_invertMovementTimer')) {
        invertMovementControls();
    }
}

//Effects should revert to default before exiting a level
//so that they can be cleanly re-applied next time you enter
function CleanupOnExit() {
    StopMatrixMode(True);  //matrix
    player().bWarrenEMPField = false;  //emp
    player().JumpZ = player().Default.JumpZ;  //disable_jump
    player().Default.GroundSpeed = DefaultGroundSpeed;  //gotta_go_fast and gotta_go_slow
    UndoLamThrowers(); //lamthrower
    SetIcePhysics(False); //ice_physics
    player().bBehindView = False; //third_person
    SetFloatyPhysics(False);
    if (isTimerActive('cc_invertMouseTimer')) {
        player().bInvertMouse = dxr.flagbase.GetBool('cc_InvertMouseDef');
    }

    if (isTimerActive('cc_invertMovementTimer')) {
        invertMovementControls();
    }

}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                                   TIMER DISPLAY HANDLING                                                 ////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
    
    timer = Spawn(class'DXRandoCrowdControlTimer', player(),,player().Location);
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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                                   TIMER COUNTER HANDLING                                                 ////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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


function int getTimer(name timerName) {
    if( datastorage == None ) datastorage = class'DataStorage'.static.GetObj(dxr);
    return int(datastorage.GetConfigKey(timerName));
}

function setTimerFlag(name timerName, int time, bool newTimer) {
    local int expiration;
    if( datastorage == None ) datastorage = class'DataStorage'.static.GetObj(dxr);
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



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                                        UTILITY FUNCTIONS                                                 ////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////



function float retrieveFloatValue(name valName) {
    if( datastorage == None ) datastorage = class'DataStorage'.static.GetObj(dxr);
    return float(datastorage.GetConfigKey(valName));
}

function storeFloatValue(name valName, float val) {
    if( datastorage == None ) datastorage = class'DataStorage'.static.GetObj(dxr);
    datastorage.SetConfig(valName, val, 3600*12);

}




function StartMatrixMode() {
    if (player().Sprite == None)
    {
        player().Matrix();
    }
}

function StopMatrixMode(optional bool silent) {
    if (player().Sprite!=None) {
        player().Matrix();
    }

    if (!silent) {
        PlayerMessage("Your powers fade...");
    }

}

function bool IsGrenade(inventory i) {
    return (i.IsA('WeaponLAM') || i.IsA('WeaponGasGrenade') || i.IsA ('WeaponEMPGrenade') || i.IsA('WeaponNanoVirusGrenade'));
}

function SkillPointsRemove(int numPoints) {
    player().SkillPointsAvail -= numPoints;
    player().SkillPointsTotal -= numPoints;

    if ((DeusExRootWindow(player().rootWindow) != None) &&
        (DeusExRootWindow(player().rootWindow).hud != None) && 
        (DeusExRootWindow(player().rootWindow).hud.msgLog != None))
    {
        PlayerMessage(Sprintf(player().SkillPointsAward, -numPoints));
        DeusExRootWindow(player().rootWindow).hud.msgLog.PlayLogSound(Sound'LogSkillPoints');
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
    return class<Augmentation>(ccLink.ccModule.GetClassFromString(type, class'Augmentation'));
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
    anAug = player().AugmentationSystem.FindAugmentation(giveClass);
    
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
    
    if(player().AugmentationSystem.AreSlotsFull(anAug)) {
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
    player().AugmentationSystem.AugLocs[anAug.AugmentationLocation].augCount++;
    
    // Assign hot key to new aug 
    // (must be after before augCount is incremented!)
    anAug.HotKeyNum = player().AugmentationSystem.AugLocs[anAug.AugmentationLocation].augCount + player().AugmentationSystem.AugLocs[anAug.AugmentationLocation].KeyBase;


    if ((!anAug.bAlwaysActive) && (player().bHUDShowAllAugs))
        player().AddAugmentationDisplay(anAug);   
    PlayerMessage(viewer@"gave you the "$anAug.AugmentationName$" augmentation");
    return Success;
}

function int AddCredits(int amount,string viewer) {
    //Reject requests to remove credits if the player doesn't have any
    if (player().Credits == 0  && amount<0) {
        return Failed;
    }
    
    player().Credits += amount;
    
    if (amount>0) {
        PlayerMessage(viewer@"gave you "$amount$" credits!");
    } else {
        PlayerMessage(viewer@"took away "$(-amount)$" credits!");        
    }
    
    if (player().Credits < 0) {
        player().Credits = 0;
    }
    return Success;
}

//This just doesn't normally exist
function int RemoveAug(Class<Augmentation> giveClass, string viewer) {
    local Augmentation anAug;
    local bool wasActive;
    
    // Checks to see if the player already has it, so we can decrease the level,
    // or remove it all together
    anAug = player().AugmentationSystem.FindAugmentation(giveClass);
    
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
    
    class'DXRAugmentations'.static.RemoveAug(player(),anAug);
    
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
    if (None == DeusExRootWindow(player().rootWindow)) {
        return False;
    }
    
    if (None == DeusExRootWindow(player().rootWindow).hud) {
        return False;
    }
    
    if (!DeusExRootWindow(player().rootWindow).hud.isVisible()){
        return False;
    }
    
    return True;
}


function int GiveLamThrower(string viewer)
{
    local Inventory anItem;

    if (isTimerActive('cc_lamthrowerTimer')) {
        return TempFail;
    }
    
    anItem = player().FindInventoryType(class'WeaponFlamethrower');
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
        KeyName = player().ConsoleCommand("KEYNAME "$i);
        if (KeyName!="") {
            Alias = player().ConsoleCommand("KEYBINDING "$KeyName);
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
        player().ConsoleCommand("SET InputExt "$fwdInputs[i]$" MoveBackward");
    }
    for (i=0;i<numBack;i++){
        player().ConsoleCommand("SET InputExt "$backInputs[i]$" MoveForward");
    }
    for (i=0;i<numRight;i++){
        player().ConsoleCommand("SET InputExt "$rightInputs[i]$" StrafeLeft");
    }
    for (i=0;i<numLeft;i++){
        player().ConsoleCommand("SET InputExt "$leftInputs[i]$" StrafeRight");
    }    
    
}

function floorIsLava() {
    local vector v;
    local vector loc;
    loc.X = player().Location.X;
    loc.Y = player().Location.Y;
    loc.Z = player().Location.Z - 1;
    if (
        ( player().Base.IsA('LevelInfo') || player().Base.IsA('Mover') )
#ifdef vanilla
        && player().bOnLadder==False
#endif
    ) {
        lavaTick++;
        //PlayerMessage("Standing on Lava! "$lavaTick);
    } else {
        lavaTick = 0;
        //PlayerMessage("Not Lava "$player().Base);
        return;
    }
    
    if ((lavaTick % 10)==0) { //If you stand on lava for 1 second
        player().TakeDamage(10,player(),loc,v,'Burned');
    }
    
    if ((lavaTick % 50)==0) { //if you stand in lava for 5 seconds
        player().CatchFire(player());
    }
}

function int GiveItem(string viewer, string type, optional int amount) {
    local int i;
    local class<Inventory> itemclass;
    local string outMsg;
    local Inventory item;
    
    if( amount < 1 ) amount = 1;
    
    itemclass = class<Inventory>(ccLink.ccModule.GetClassFromString(type,class'Inventory'));
    
    if (itemclass == None) {
        return NotAvail;
    }
    
    for (i=0;i<amount;i++) {
        item = class'DXRActorsBase'.static.GiveItem(player(), itemclass);
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
    if (player().InConversation()) {
        return TempFail;
    }

    c = class<DeusExProjectile>(ccLink.ccModule.GetClassFromString(type, class'DeusExProjectile'));
    if( c == None ) return NotAvail;
    p = Spawn( c, player(),,player().Location);
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
        if (class'DXRActorsBase'.static.IsHuman(p) && p!=player() && !p.bHidden && !p.bStatic && p.bInWorld && p.Orders!='Sitting') {
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
    
    ccLink.ccModule.Swap(player(),a);
    player().ViewRotation = player().Rotation;
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
    player().MoveSmooth(newAccel);
    
    //Play an oof sound
    player().PlaySound(Sound'DeusExSounds.Player.MalePainSmall');
    
    PlayerMessage(viewer@"nudged you a little bit");

}

function AskRandomQuestion(String viewer) {
    
    local string question;
    local string answers[3];
    local int numAnswers;
    
    ccLink.ccModule.getRandomQuestion(question,numAnswers,answers[0],answers[1],answers[2]);
    
    ccLink.ccModule.CreateCustomMessageBox(viewer$" asks...",question,numAnswers,answers,ccLink.ccModule,1,True);
    
}

function bool canDropItem() {
	local Vector X, Y, Z, dropVect;
	local Inventory item;
    
    item = player().InHand;
    
    if (item == None) {
        return False;
    }
    
	GetAxes(player().Rotation, X, Y, Z);
	dropVect = player().Location + (player().CollisionRadius + 2*item.CollisionRadius) * X;
	dropVect.Z += player().BaseEyeHeight;
    
	// check to see if we're blocked by terrain
	if (!player().FastTrace(dropVect))
	{
		return False;
	}
    
    return True;

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

function PlayerMessage(string msg)
{
    log(Self$": "$msg);
    class'DXRTelemetry'.static.SendLog(dxr, Self, "INFO", msg);
    player().ClientMessage(msg, 'CrowdControl', true);
}

function err(string msg)
{
    log(Self$": ERROR: "$msg);
    class'DXRTelemetry'.static.SendLog(dxr, Self, "ERROR", msg);
    player().ClientMessage(msg, 'ERROR', true);
}

function info(string msg)
{
    log(Self$": INFO: "$msg);
    class'DXRTelemetry'.static.SendLog(dxr, Self, "INFO", msg);
}

simulated final function #var PlayerPawn  player()
{
    return dxr.flags.player();
}














/////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                                  CROWD CONTROL EFFECT MAPPING                                       ////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////


function int doCrowdControlEvent(string code, string param[5], string viewer, int type) {
    local int i;

    switch(code) {
        case "poison":
            if (!InGame()) {
                return TempFail;
            }
        
            player().StartPoison(player(),5);
            PlayerMessage(viewer@"poisoned you!");
            break;

        case "kill":
            player().Died(player(),'CrowdControl',player().Location);
            PlayerMessage(viewer@"set off your killswitch!");
            player().MultiplayerDeathMsg(player(),False,True,viewer,"triggering your kill switch");
            break;

        case "glass_legs":
            player().HealthLegLeft=1;
            player().HealthLegRight=1;
            player().GenerateTotalHealth();
            PlayerMessage(viewer@"gave you glass legs!");
            break;

        case "give_health":
            if (player().Health == 100) {
                return TempFail;
            }
            player().HealPlayer(Int(param[0]),False);
            PlayerMessage(viewer@"gave you "$param[0]$" health!");
            break;

        case "set_fire":
            player().CatchFire(player());
            PlayerMessage(viewer@"set you on fire!");
            break;

        case "full_heal":
            if (player().Health == 100) {
                return TempFail;
            }
            player().RestoreAllHealth();
            PlayerMessage(viewer@"fully healed you!");
            break;

        case "disable_jump":
            if (player().JumpZ == 0) {
                return TempFail;
            }

            player().JumpZ = 0;
            startnewTimer('cc_JumpTimer');
            PlayerMessage(viewer@"made your knees lock up.");
            break;

        case "gotta_go_fast":
            if (DefaultGroundSpeed != player().Default.GroundSpeed) {
                return TempFail;
            }
            storeFloatValue('cc_moveSpeedModifier',MoveSpeedMultiplier);
            player().Default.GroundSpeed = DefaultGroundSpeed * moveSpeedMultiplier;
            startNewTimer('cc_SpeedTimer');
            PlayerMessage(viewer@"made you fast like Sonic!");
            break;

        case "gotta_go_slow":
            if (DefaultGroundSpeed != player().Default.GroundSpeed) {
                return TempFail;
            }
            storeFloatValue('cc_moveSpeedModifier',MoveSpeedDivisor);
            player().Default.GroundSpeed = DefaultGroundSpeed * moveSpeedDivisor;
            startNewTimer('cc_SpeedTimer');
            PlayerMessage(viewer@"made you slow like a snail!");
            break;
        case "drunk_mode":
            if (player().drugEffectTimer<30.0) {
                player().drugEffectTimer+=60.0;
            } else {
                return TempFail;
            }
            PlayerMessage(viewer@"got you tipsy!");
            break;

        case "drop_selected_item":
            if (player().InHand == None) {
                return TempFail;
            }
            
            if (canDropItem() == False) {
                return TempFail;
            }
            
            if (player().DropItem() == False) {
                return TempFail;
            }
            PlayerMessage(viewer@"made you fumble your item");
            break;

        case "emp_field":
            player().bWarrenEMPField = true;
            startNewTimer('cc_EmpTimer');
            PlayerMessage(viewer@"made electronics allergic to you");
            break;

        case "matrix":
            if (player().Sprite!=None) {
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
            player().bBehindView=True;
            startNewTimer('cc_behindTimer');
            PlayerMessage(viewer@"gave you an out of body experience");
            break;

        case "give_energy":
            
            if (player().Energy == player().EnergyMax) {
                return TempFail;
            }
            //Copied from BioelectricCell

            //PlayerMessage("Recharged 10 points");
            player().PlaySound(sound'BioElectricHiss', SLOT_None,,, 256);

            player().Energy += Int(param[0]);
            if (player().Energy > player().EnergyMax)
                player().Energy = player().EnergyMax;

            PlayerMessage(viewer@"gave you "$param[0]$" energy!");
            break;

        case "give_skillpoints":
            i = Int(param[0])*100;
            PlayerMessage(viewer@"gave you "$i$" skill points");
            player().SkillPointsAdd(i);
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
            dxr.flagbase.SetBool('cc_InvertMouseDef',player().bInvertMouse);

            player().bInvertMouse = !player().bInvertMouse;
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

defaultproperties
{
    NormalGravity=vect(0,0,-950)
    FloatGrav=vect(0,0,0.15)
    MoonGrav=vect(0,0,-300)
}
