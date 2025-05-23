Class DXRCrowdControlEffects extends Info;

var DXRandoCrowdControlLink ccLink;

var DataStorage datastorage;
var transient DXRando dxr;
var transient DXRCameraModes dxrCameras;
var string shouldSave;

const Success = 0;
const Failed = 1;
const NotAvail = 2;
const TempFail = 3;

const CCType_Test       = 0x00;
const CCType_Start      = 0x01;
const CCType_Stop       = 0x02;
const CCType_PlayerInfo = 0xE0; //Not used for us
const CCType_Login      = 0xF0; //Not used for us
const CCType_KeepAlive  = 0xFF; //Not used for us

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
const FloatyTimeDefault = 30;
const FloorLavaTimeDefault = 60;
const InvertMouseTimeDefault = 60;
const InvertMovementTimeDefault = 60;
const EarthquakeTimeDefault = 30;
const CameraRollTimeDefault = 60;
const EatBeansTimeDefault = 60;
const ResidentEvilTimeDefault = 60;
const RadiationTimeDefault = 60;
const DoomModeTimeDefault = 60;
const WineBulletsTimeDefault = 60;
const BloodTimeDefault = 60;

const MAX_NASTY_RAT = 3;
const MAX_SPAM_CUBES = 50;
const MAX_MARBLES = 100;
const MAX_PIANOS = 50;
const MAX_LAVA_FIRE = 100;

//OBSOLETE - Remove eventually
struct ZoneFriction
{
    var name zonename;
    var float friction;
};
var ZoneFriction zone_frictions[32];

//OBSOLETE - Remove eventually
struct ZoneGravity
{
    var name zonename;
    var vector gravity;
};
var ZoneGravity zone_gravities[32];


struct AugEffectState
{
    var bool canUpgrade;
    var bool canDowngrade;
};

var DXRandoCrowdControlTimer timerDisplays[32];

var DXRandoCrowdControlPawn CrowdControlPawns[3];

var transient AugEffectState AugEffectStates[32]; //Vanilla has a 25 array, but in case mods bump it up?
var transient bool AugEffectStatesInit;

var transient bool HaveFlamethrower;
var transient bool FlamethrowerInit;

var bool effectSelectInit;

var int mostRecentCcPawn;

var int fartSoundId;
var int fartDuration;

var int flashbangSoundId;
var int flashbangDuration;

var Texture coronaTexture;

var bool quickLoadTriggered;
var bool trainingTriggered;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                                  CROWD CONTROL FRAMEWORK                                                 ////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function Init(DXRandoCrowdControlLink crowd_control_link, DXRando tdxr)
{
    ccLink = crowd_control_link;
    dxr = tdxr;

    lavaTick = 0;
    mostRecentCcPawn = 0;

    effectSelectInit=False;
    quickLoadTriggered=False; //Disable the quick load effect, in case you managed to save with the quick load effect pending
    trainingTriggered=False; //Disable the training effect, in case you managed to save with the training effect pending
}

function DXRandoCrowdControlPawn GetCrowdControlPawn(string UserName)
{
    mostRecentCcPawn++;
    if (mostRecentCcPawn>=ArrayCount(CrowdControlPawns)){
        mostRecentCcPawn=0;
    }

    if (CrowdControlPawns[mostRecentCcPawn]==None){
        CrowdControlPawns[mostRecentCcPawn]=Spawn(class'DXRandoCrowdControlPawn');
    }

    CrowdControlPawns[mostRecentCcPawn].familiarName = UserName;
    return CrowdControlPawns[mostRecentCcPawn];
}

//#region Periodic Updates
function PeriodicUpdates()
{

    if (dxr.OnTitleScreen()){
        return;
    }

    //Matrix Mode Timer
    if (decrementTimer('cc_MatrixModeTimer')) {
        StopCrowdControlEvent("matrix",true);
    }

    //EMP Field timer
    if (decrementTimer('cc_EmpTimer')) {
        StopCrowdControlEvent("emp_field",true);
    }

    if (isTimerActive('cc_JumpTimer')) {
        player().JumpZ = 0;
    }
    if (decrementTimer('cc_JumpTimer')) {
        StopCrowdControlEvent("disable_jump",true);
    }

    if (isTimerActive('cc_SpeedTimer')) {
        player().Default.GroundSpeed = DefaultGroundSpeed * retrieveFloatValue('cc_moveSpeedModifier');
    }
    if (decrementTimer('cc_SpeedTimer')) {
        StopCrowdControlEvent("gotta_go_fast",true); //also gotta_go_slow
    }

    if (decrementTimer('cc_lamthrowerTimer')) {
        StopCrowdControlEvent("lamthrower",true);
    }

    if (decrementTimer('cc_iceTimer')) {
        StopCrowdControlEvent("ice_physics",true);
    }

    if (isTimerActive('cc_behindTimer')){
        dxrCameras.EnableTempThirdPerson();
    }
    if (decrementTimer('cc_behindTimer')) {
        StopCrowdControlEvent("third_person",true);
    }

    if (decrementTimer('cc_DifficultyTimer')){
        StopCrowdControlEvent("dmg_double",true); //also dmg_half
    }

    if (decrementTimer('cc_floatyTimer')) {
        StopCrowdControlEvent("floaty_physics",true);
    }

    if (decrementTimer('cc_floorLavaTimer')) {
        StopCrowdControlEvent("floor_is_lava",true);
    }

    if (decrementTimer('cc_invertMouseTimer')) {
        StopCrowdControlEvent("invert_mouse",true);
    }

    if (decrementTimer('cc_invertMovementTimer')) {
        StopCrowdControlEvent("invert_movement",true);
    }

    if (decrementTimer('cc_Earthquake')) {
        StopCrowdControlEvent("earthquake",true);
    }

    //Re-apply the quake, just in case some other shake happened and ended during the timer (ie. superfreighter)
    if (isTimerActive('cc_Earthquake')){
        startEarthquake(getTimer('cc_Earthquake'));
    }

    if (decrementTimer('cc_RollTimer')) {
        StopCrowdControlEvent("barrel_roll",true); //also "flipped" and "limp_neck"
    }

    if (decrementTimer('cc_EatBeans')) {
        StopCrowdControlEvent("eat_beans",true);
    } else if (isTimerActive('cc_EatBeans') && !InMenu()){
        Fart();
    }

    if (isTimerActive('cc_ResidentEvil')){
        dxrCameras.EnableTempFixedCamera();
    }
    if (decrementTimer('cc_ResidentEvil')) {
        StopCrowdControlEvent("resident_evil",true);
    }

    if (flashbangDuration>0){
        flashbangDuration--;
        if (flashbangDuration==0){
            player().StopSound(flashbangSoundId);
            flashbangSoundId=0;
        }
    }

    if (quickLoadTriggered){
        quickLoadTriggered = False;
        player().QuickLoadConfirmed();
    }

    if (trainingTriggered){
        trainingTriggered = False;
        Player().FlagBase.DeleteFlag('Rando_seed',FLAG_Int); //Delete the seed flag so the training is random
        Level.Game.SendPlayer(Player(),"00_TRAINING"); //Should this try to vary to mirrored?
    }

    if (isTimerActive('cc_Radioactive')){
        PlayerRadiates();
    }
    if (decrementTimer('cc_Radioactive')){
        StopCrowdControlEvent("radioactive",true);
    }

#ifdef vanilla
    if (isTimerActive('cc_DoomMode')){
        Player().bDoomMode=True;
    } else {
        Player().bDoomMode=False;
    }
#endif
    if (decrementTimer('cc_DoomMode')){
        StopCrowdControlEvent("doom_mode",true);
    }

    if (decrementTimer('cc_WineBullets')){
        StopCrowdControlEvent("wine_bullets",true);
    }

    if (decrementTimer('cc_BloodGod')){
        StopCrowdControlEvent("blood_god",true);
    }
}
//#endregion

//#region Effect Select
function HandleEffectSelectability()
{
    local Inventory anItem;
    local bool haveFT, canFreelySave;
    local DXRLoadouts loadout;

    if (dxr.OnTitleScreen()){
        return;
    }

    //LamThrower
    if (#defined(vanilla)){
        anItem = player().FindInventoryType(class'WeaponFlamethrower');
        haveFT=(anItem!=None);
        if (haveFT!=HaveFlamethrower || !FlamethrowerInit){
            ccLink.sendEffectSelectability("lamthrower",haveFT);
            HaveFlamethrower=haveFT;
        }
        FlamethrowerInit=True;
    }

    //Effects that won't change state during a given level, so only need to be set once
    if (effectSelectInit==False){
        ccLink.sendEffectSelectability("third_person",!dxrCameras.IsThirdPersonGame());
        ccLink.sendEffectSelectability("resident_evil",!dxrCameras.IsFixedCamGame());

#ifdef vanilla
        canFreelySave=class'DXRAutosave'.static.AllowManualSaves(player(),True);
#else
        canFreelySave=True; //Revision has a "no manual saving" mode, but it isn't accessible through rando at the moment
#endif
        ccLink.sendEffectSelectability("quick_save",canFreelySave);
        ccLink.sendEffectSelectability("quick_load",canFreelySave);
        ccLink.sendEffectSelectability("wine_bullets",#defined(vanilla));
        ccLink.sendEffectSelectability("blood_god",!Level.Game.bLowGore && !Level.Game.bVeryLowGore); //Blood doesn't spawn with low gore
        ccLink.sendEffectSelectability("random_clothes",!#defined(vmd));
        ccLink.sendEffectSelectability("back_to_academy",!IsTrainingLevel());

        loadout = DXRLoadouts(ccLink.dxr.FindModule(class'DXRLoadouts'));
        if (loadout!=None){
            //Items
            HandleItemLoadoutSelectability(loadout,"medkit");
            HandleItemLoadoutSelectability(loadout,"bioelectriccell");
            HandleItemLoadoutSelectability(loadout,"fireextinguisher");
            HandleItemLoadoutSelectability(loadout,"ballisticarmor");
            HandleItemLoadoutSelectability(loadout,"lockpick");
            HandleItemLoadoutSelectability(loadout,"multitool");
            HandleItemLoadoutSelectability(loadout,"rebreather");
            HandleItemLoadoutSelectability(loadout,"adaptivearmor");
            HandleItemLoadoutSelectability(loadout,"hazmatsuit");
            HandleItemLoadoutSelectability(loadout,"winebottle");
            HandleItemLoadoutSelectability(loadout,"techgoggles");

            //Weapons
            HandleItemLoadoutSelectability(loadout,"weaponflamethrower");
            HandleItemLoadoutSelectability(loadout,"weapongepgun");
            HandleItemLoadoutSelectability(loadout,"weaponnanosword");
            HandleItemLoadoutSelectability(loadout,"weaponplasmarifle");
            HandleItemLoadoutSelectability(loadout,"weaponlaw");
            HandleItemLoadoutSelectability(loadout,"weaponrifle");
            HandleItemLoadoutSelectability(loadout,"weaponassaultgun");
            HandleItemLoadoutSelectability(loadout,"weaponassaultshotgun");
            HandleItemLoadoutSelectability(loadout,"weaponbaton");
            HandleItemLoadoutSelectability(loadout,"weaponcombatknife");
            HandleItemLoadoutSelectability(loadout,"weaponcrowbar");
            HandleItemLoadoutSelectability(loadout,"weaponminicrossbow");
            HandleItemLoadoutSelectability(loadout,"weaponpeppergun");
            HandleItemLoadoutSelectability(loadout,"weaponpistol");
            HandleItemLoadoutSelectability(loadout,"weaponstealthpistol");
            HandleItemLoadoutSelectability(loadout,"weaponprod");
            HandleItemLoadoutSelectability(loadout,"weaponsawedoffshotgun");
            HandleItemLoadoutSelectability(loadout,"weaponshuriken");
            HandleItemLoadoutSelectability(loadout,"weaponsword");
            HandleItemLoadoutSelectability(loadout,"weaponlam");
            HandleItemLoadoutSelectability(loadout,"weaponempgrenade");
            HandleItemLoadoutSelectability(loadout,"weapongasgrenade");
            HandleItemLoadoutSelectability(loadout,"weaponnanovirusgrenade");
            HandleItemLoadoutSelectability(loadout,"weaponhideagun");

            //Ammo
            HandleItemLoadoutSelectability(loadout,"ammo10mm");
            HandleItemLoadoutSelectability(loadout,"ammo20mm");
            HandleItemLoadoutSelectability(loadout,"ammo762mm");
            HandleItemLoadoutSelectability(loadout,"ammo3006");
            HandleItemLoadoutSelectability(loadout,"ammobattery");
            HandleItemLoadoutSelectability(loadout,"ammodart");
            HandleItemLoadoutSelectability(loadout,"ammodartflare");
            HandleItemLoadoutSelectability(loadout,"ammodartpoison");
            HandleItemLoadoutSelectability(loadout,"ammonapalm");
            HandleItemLoadoutSelectability(loadout,"ammopepper");
            HandleItemLoadoutSelectability(loadout,"ammoplasma");
            HandleItemLoadoutSelectability(loadout,"ammorocket");
            HandleItemLoadoutSelectability(loadout,"ammorocketwp");
            HandleItemLoadoutSelectability(loadout,"ammosabot");
            HandleItemLoadoutSelectability(loadout,"ammoshell");
        }

        effectSelectInit=True;
    }

    HandleAugEffectSelectability("augspeed");
    HandleAugEffectSelectability("augtarget");
    HandleAugEffectSelectability("augcloak");
    HandleAugEffectSelectability("augballistic");
    HandleAugEffectSelectability("augradartrans");
    HandleAugEffectSelectability("augshield");
    HandleAugEffectSelectability("augenviro");
    HandleAugEffectSelectability("augemp");
    HandleAugEffectSelectability("augcombat");
    HandleAugEffectSelectability("aughealing");
    HandleAugEffectSelectability("augstealth");
    HandleAugEffectSelectability("augmuscle");
    HandleAugEffectSelectability("augvision");
    HandleAugEffectSelectability("augdrone");
    HandleAugEffectSelectability("augdefense");
    HandleAugEffectSelectability("augaqualung");
    HandleAugEffectSelectability("augheartlung");
    HandleAugEffectSelectability("augpower");
    AugEffectStatesInit=True;
}

function HandleItemLoadoutSelectability(DXRLoadouts loadout, string invName)
{
    local class<Inventory> invClass;

    invClass=getInvClass(invName);
    //player().ClientMessage("give_"$invName$"   "$!loadout.is_banned(invClass));
    ccLink.sendEffectSelectability("give_"$invName,!loadout.is_banned(invClass));
}

function HandleAugEffectSelectability(string augName)
{
    local bool canUpgrade,canDowngrade,sendUpgradeUpdate,sendDowngradeUpdate;
    local int augLevel,augMax, augIndex;
    local class<Augmentation> augClass;
    local Augmentation anAug;

    augClass=getAugClass(augName);
    augIndex=getAugManagerIndex(augClass);
    augLevel=FindAugLevel(augClass);
    augMax=FindAugMax(augClass);
    anAug = player().AugmentationSystem.FindAugmentation(augClass);

    if (augLevel==-1){
        canUpgrade=!player().AugmentationSystem.AreSlotsFull(anAug);
        canDowngrade=False;
    } else if (augLevel==augMax){
        canUpgrade=False;
        canDowngrade=True;
    } else {
        canUpgrade=True;
        canDowngrade=True;
    }

    if (!AugEffectStatesInit){
       sendUpgradeUpdate=True;
       sendDowngradeUpdate=True;
    } else {
        if (AugEffectStates[augIndex].canUpgrade!=canUpgrade){
            sendUpgradeUpdate=True;
        }

        if (AugEffectStates[augIndex].canDowngrade!=canDowngrade){
            sendDowngradeUpdate=True;
        }
    }

    if (sendUpgradeUpdate){
        ccLink.sendEffectSelectability("add_"$augName,canUpgrade);
        AugEffectStates[augIndex].canUpgrade=canUpgrade;

    }

    if (sendDowngradeUpdate){
        ccLink.sendEffectSelectability("rem_"$augName,canDowngrade);
        AugEffectStates[augIndex].canDowngrade=canDowngrade;
    }
}
//#endregion

function int getAugManagerIndex(class<Augmentation> augClass)
{
    local int i;
    for (i=0;i<ArrayCount(player().AugmentationSystem.augClasses);i++){
        if (player().AugmentationSystem.augClasses[i]==augClass){
            return i;
        }
    }
    return -1;
}

function int FindAugLevel(class<Augmentation> augClass)
{
    local Augmentation anAug;
    anAug = player().AugmentationSystem.FindAugmentation(augClass);

    if (anAug==None){
        return -1;
    } else {
        if (anAug.bHasIt){
            return anAug.CurrentLevel;
        } else {
            return -1;
        }
    }
}
function int FindAugMax(class<Augmentation> augClass)
{
    return augClass.default.MaxLevel;
}

function bool IsTrainingLevel()
{
    switch(dxr.localURL) {
    case "00_Training":
    case "00_TrainingCombat":
    case "00_TrainingFinal":
        return true;
    }
    return false;
}
//Start the sound and fire the clouds
function Fart()
{
    local Rotator r;
    local int i;

    r = player().Rotation;
    r.Yaw+=(32768-5000); //Fire out the behind

    //Fart Sound
    fartSoundId = player().PlaySound(sound'PushMetal',SLOT_Pain, 2,,,0.5+FRand());
    fartDuration = Rand(3)+1; //Duration in 10ths of a second
    player().AISendEvent('LoudNoise', EAITYPE_Audio, 2.0, 512);

    for (i=0;i<5;i++){
        if (player().bOnFire){
            Spawn(class'Fireball', player(),,player().Location,r);
        } else {
            if (Rand(2)==0){
                Spawn(class'TearGas', player(),,player().Location,r);
            } else {
                Spawn(class'PoisonGas', player(),,player().Location,r);
            }
        }
        r.Yaw+=2500;
    }

    player().Velocity += Vector(player().ViewRotation) * 8 * fartDuration; //Fart pushes you in the direction you're looking
}

//#region Continuous Updates
function ContinuousUpdates()
{
    local int roll;
    local DataStorage datastorage;
    datastorage = class'DataStorage'.static.GetObjFromPlayer(self);

    if (dxr.OnTitleScreen()){
        return;
    }

    //Lava floor logic
    if (isTimerActive('cc_floorLavaTimer') && InGame() && !InMenu()){
        floorIsLava();
    }

    //Blood God logic
    if (isTimerActive('cc_BloodGod') && !InMenu()){
        BloodForTheBloodGod();
    }

    //Camera Spin
    if (bool(datastorage.GetConfigKey('cc_cameraSpin')) && InGame()){
        roll = int(datastorage.GetConfigKey('cc_cameraRoll'));
        roll+=110;  //This rate makes about one full rotation in a minute
        roll = roll % 65535;
        datastorage.SetConfig('cc_cameraRoll',roll, 3600*12);


    }

    if (fartSoundId!=0){
        fartDuration--;
        if (fartDuration <= 0){
            player().StopSound(fartSoundId);
            fartSoundId=0;
        }
    }


}
//#endregion



//#region Enter/Exit
//Gets called on every level entry
//Some effects need to be reapplied on each level entry (eg. ice physics)
//Make sure to do that here
function InitOnEnter() {
    local inventory anItem;

    if (dxr.OnTitleScreen()){
        return;
    }

    datastorage = class'DataStorage'.static.GetObjFromPlayer(self);

    dxrCameras = DXRCameraModes(dxr.FindModule(class'DXRCameraModes'));
    if (dxrCameras==None){
        player().ClientMessage("Couldn't find cameras module");
    }

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

    if (isTimerActive('cc_behindTimer')){
        dxrCameras.EnableTempThirdPerson();
    } else if (isTimerActive('cc_ResidentEvil')){
        dxrCameras.EnableTempFixedCamera();
    } else {
        dxrCameras.DisableTempCamera();
    }

    if (0==retrieveFloatValue('cc_damageMult')) {
        storeFloatValue('cc_damageMult',1.0);
    }
    if (!isTimerActive('cc_DifficultyTimer')) {
        storeFloatValue('cc_damageMult',1.0);
    }

    if (isTimerActive('cc_invertMouseTimer')) {
        player().bInvertMouse = !bool(datastorage.GetConfigKey('cc_InvertMouseDef'));
    }

    if (isTimerActive('cc_invertMovementTimer')) {
        invertMovementControls();
    }

    if (isTimerActive('cc_Earthquake')) {
        startEarthquake(getTimer('cc_Earthquake'));
    } else {
        player().shaketimer=0;
    }
}

//Effects should revert to default before exiting a level
//so that they can be cleanly re-applied next time you enter
function CleanupOnExit() {

    if (dxr==None || dxr.OnTitleScreen()){
        return;
    }

    StopMatrixMode(True);  //matrix
    player().bWarrenEMPField = false;  //emp
    player().JumpZ = player().Default.JumpZ;  //disable_jump
    player().Default.GroundSpeed = DefaultGroundSpeed;  //gotta_go_fast and gotta_go_slow
    UndoLamThrowers(); //lamthrower
    SetIcePhysics(False); //ice_physics
    dxrCameras.DisableTempCamera();
    player().bCrosshairVisible = True; //Make crosshairs show up again
    SetFloatyPhysics(False);
    if (isTimerActive('cc_invertMouseTimer')) {
        player().bInvertMouse = bool(datastorage.GetConfigKey('cc_InvertMouseDef'));
    }

    if (isTimerActive('cc_invertMovementTimer')) {
        invertMovementControls();
    }
}
//#endregion


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                                   TIMER DISPLAY HANDLING                                                 ////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//#region Timer Displays
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
//#endregion

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                                   TIMER COUNTER HANDLING                                                 ////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//#region Def Timer Times
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
        case 'cc_Earthquake':
            return EarthquakeTimeDefault;
        case 'cc_RollTimer':
            return CameraRollTimeDefault;
        case 'cc_EatBeans':
            return EatBeansTimeDefault;
        case 'cc_ResidentEvil':
            return ResidentEvilTimeDefault;
        case 'cc_Radioactive':
            return RadiationTimeDefault;
        case 'cc_DoomMode':
            return DoomModeTimeDefault;
        case 'cc_WineBullets':
            return WineBulletsTimeDefault;
        case 'cc_BloodGod':
            return BloodTimeDefault;

        default:
            PlayerMessage("Unknown timer name "$timerName);
            return 0;
    }
}
//#endregion

//#region Timer Labels
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
        case 'cc_Earthquake':
            return "Quake";
        case 'cc_RollTimer':
            return "Camera";
        case 'cc_EatBeans':
            return "Beans";
        case 'cc_ResidentEvil':
            return "Fixed Cam";
        case 'cc_Radioactive':
            return "Radiation";
        case 'cc_DoomMode':
            return "Doom";
        case 'cc_WineBullets':
            return "Wine Dmg";
        case 'cc_BloodGod':
            return "Blood God";


        default:
            PlayerMessage("Unknown timer name "$timerName);
            return "???";
    }
}
//#endregion

function setFloorIsLavaName(string lavaName)
{
    if( datastorage == None ) datastorage = class'DataStorage'.static.GetObj(dxr);
    datastorage.SetConfig("floorIsLavaName", lavaName, 3600);
}

function string getFloorIsLavaName() {
    if( datastorage == None ) datastorage = class'DataStorage'.static.GetObj(dxr);
    return datastorage.GetConfigKey("floorIsLavaName");
}

function int getTimer(name timerName) {
    if( datastorage == None ) datastorage = class'DataStorage'.static.GetObj(dxr);
    return int(datastorage.GetConfigKey(timerName));
}

function int getTimerDuration(name timerName) {
    local int duration;
    if( datastorage == None ) datastorage = class'DataStorage'.static.GetObj(dxr);

    duration = int(datastorage.GetConfigKey(timerName$"_Duration"));

    if (duration == 0) {
        duration = getDefaultTimerTimeByName(timerName);
    }

    return duration;
}

function setTimerDuration(name timerName, int duration) {
    if( datastorage == None ) datastorage = class'DataStorage'.static.GetObj(dxr);

    if (duration==0){
        duration = getDefaultTimerTimeByName(timerName);
    }
    datastorage.SetConfig(timerName$"_Duration",duration,3600*12);
}

function setTimerFlag(name timerName, int time, bool newTimer) {
    local int expiration, duration;
    if( datastorage == None ) datastorage = class'DataStorage'.static.GetObj(dxr);
    if( time == 0 ) expiration = 1;
    else expiration = 3600*12;
    datastorage.SetConfig(timerName, time, expiration);
    if (newTimer) {
        addTimerDisplay(timerName,time);
    } else {
        //This is basically just for if you reload a game, or change maps
        if (checkForTimerDisplay(timerName) == False) {
            duration = getTimerDuration(timerName);
            addTimerDisplay(timerName,duration);
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

function disableTimer(name timerName) {
    setTimerFlag(timerName,0,False);
}

function startNewTimer(name timerName, int duration) {
    if (duration==0){
        duration = getDefaultTimerTimeByName(timerName);
    }
    setTimerDuration(timerName,duration);

    setTimerFlag(timerName,duration,True);
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                                        UTILITY FUNCTIONS                                                 ////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//#region Utility Functs

function float retrieveFloatValue(name valName) {
    if( datastorage == None ) datastorage = class'DataStorage'.static.GetObj(dxr);
    return float(datastorage.GetConfigKey(valName));
}

function storeFloatValue(name valName, float val) {
    if( datastorage == None ) datastorage = class'DataStorage'.static.GetObj(dxr);
    datastorage.SetConfig(valName, val, 3600*12);

}




function StartMatrixMode() {
    local Light l;
    if (player().Sprite == None)
    {
        if (coronaTexture==None){
            //Find the corona texture used for lights in this level so it can be restored later
            foreach AllActors(class'Light',l){
                if (l.bCorona && l.Skin!=None){
                    coronaTexture = l.Skin;
                    break;
                }
            }
        }
        player().Matrix();
    }
}

function StopMatrixMode(optional bool silent) {
    local Light l;
    if (player().Sprite!=None) {
        player().Matrix();

        //Stopping Matrix mode the normal way doesn't seem to correctly set the Skin value back on lights (which use the skin for Corona)
        if (coronaTexture!=None){
            foreach AllActors(class'Light',l){
                if (l.bCorona){
                    l.Skin=coronaTexture;
                }
            }
        }
    }

    if (!silent) {
        PlayerMessage("Your powers fade...");
    }

}

function SkillPointsRemove(int numPoints) {
    player().SkillPointsAvail -= numPoints;
    //Don't add to the total.  It isn't used in the base game, but we use it for scoring.
    //These points are not lost naturally, so don't uncount them from your score
    //player().SkillPointsTotal -= numPoints;

    if ((DeusExRootWindow(player().rootWindow) != None) &&
        (DeusExRootWindow(player().rootWindow).hud != None) &&
        (DeusExRootWindow(player().rootWindow).hud.msgLog != None))
    {
        PlayerMessage(Sprintf(player().SkillPointsAward, -numPoints) $ shouldSave);
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

function class<Inventory> getInvClass(string type) {
    return class<Inventory>(ccLink.ccModule.GetClassFromString(type, class'Inventory'));
}

function class<Augmentation> getAugClass(string type) {
    return class<Augmentation>(ccLink.ccModule.GetClassFromString(type, class'Augmentation'));
}

function class<ScriptedPawn> getScriptedPawnClass(string type) {
    return class<ScriptedPawn>(ccLink.ccModule.GetClassFromString(type, class'ScriptedPawn'));
}

function class<#var(DeusExPrefix)Weapon> getWeaponClass(string type) {
    return class<#var(DeusExPrefix)Weapon>(ccLink.ccModule.GetClassFromString(type, class'#var(DeusExPrefix)Weapon'));
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
        if (!class'DXRAugmentations'.static.AugCanBeUpgraded(anAug)) {
            PlayerMessage(viewer@"wanted to upgrade "$anAug.AugmentationName$" but it cannot be upgraded any further");
            return Failed;
        }

        class'DXRAugmentations'.static.UpgradeAug(anAug);
        class'DXRAugmentations'.static.RedrawAugMenu(player());
        PlayerMessage(viewer@"upgraded "$anAug.AugmentationName$" to level "$anAug.CurrentLevel+1 $ shouldSave);
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

    class'DXRAugmentations'.static.RedrawAugMenu(player());

    PlayerMessage(viewer@"gave you the "$anAug.AugmentationName$" augmentation" $ shouldSave);
    return Success;
}

function int AddCredits(int amount,string viewer) {
    //Reject requests to remove credits if the player doesn't have any
    if (player().Credits == 0  && amount<0) {
        return Failed;
    }

    player().Credits += amount;

    if (amount>0) {
        PlayerMessage(viewer@"gave you "$amount$" credits!" $ shouldSave);
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
        class'DXRAugmentations'.static.RedrawAugMenu(player());
        return Success;
    }

    class'DXRAugmentations'.static.RemoveAug(player(),anAug);
    class'DXRAugmentations'.static.RedrawAugMenu(player());

    PlayerMessage(viewer@"removed your "$anAug.AugmentationName$" augmentation");
    return Success;
}


function float GetDefaultZoneFriction(ZoneInfo z)
{
    local DXRStoredZoneInfo szi;

    szi = class'DXRStoredZoneInfo'.static.Find(z);
    if (szi==None) return NormalFriction;
    return szi.ZoneGroundFriction;
}

function vector GetDefaultZoneGravity(ZoneInfo z)
{
    local DXRStoredZoneInfo szi;

    szi = class'DXRStoredZoneInfo'.static.Find(z);
    if (szi==None) return NormalGravity;
    return szi.ZoneGravity;
}

function SetFloatyPhysics(bool enabled) {
    local ZoneInfo Z;

    local Actor A;
    local bool apply;

    ForEach AllActors(class'ZoneInfo', Z)
    {
        log("SetFloatyPhysics "$Z$" gravity: "$Z.ZoneGravity);
        if (enabled && Z.ZoneGravity != FloatGrav ) {
            Z.ZoneGravity = FloatGrav;
        }
        else if ( (!enabled) && Z.ZoneGravity == FloatGrav ) {
            Z.ZoneGravity = GetDefaultZoneGravity(Z);
        }
    }

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
                        (A.Physics == PHYS_None || A.Physics == PHYS_Falling) &&
                        A.bStatic == False &&
                        A.bHidden == False &&
                        Decoration(A).bPushable == True) || A.isa('Carcass'));
        } else if (A.isa('Inventory')) {
            apply = (Pawn(A.Owner) == None);
        }

        if (apply) {
            if (enabled){
                A.Velocity.Z+=Rand(10)+1;
                A.SetPhysics(PHYS_Falling);
            } else {
                if (Pawn(A)!=None && A.Region.Zone.bWaterZone){
                    A.SetPhysics(PHYS_Swimming);
                } else {
                    A.SetPhysics(PHYS_Falling);
                }
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

    //"Paused" with the pause button
    if ( (Level.Pauser != "") && (Level.LevelAction == LEVACT_None) ){
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

function bool InConversation() {
    return player().conPlay!=None;
}

function bool InMenu() {
    return !InGame() && !InConversation();
}

function int GiveLamThrower(string viewer,int duration)
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

    if (duration==0){
        duration = LamThrowerTimeDefault;
    }
    setTimerDuration('cc_lamthrowerTimer',duration);
    setTimerFlag('cc_lamthrowerTimer',duration,True);
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

    GenerateFloorLavaFire();

    if (
        ( player().Base.IsA('LevelInfo') || player().Base.IsA('Mover') )
#ifdef vanilla || revision
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
        player().TakeDamage(10,GetCrowdControlPawn(getFloorIsLavaName()),loc,v,'Burned');
    }

    if ((lavaTick % 50)==0) { //if you stand in lava for 5 seconds
        player().CatchFire(GetCrowdControlPawn(getFloorIsLavaName()));
    }
}

function DestroyAllLavaFire()
{
    local LavaFire f;
    foreach AllActors(class'LavaFire',f,'FloorIsLavaFire'){
        f.Destroy();
    }
}

//This whole thing is madness
function GenerateFloorLavaFire()
{
    local LavaFire f;
    local int num,numToSpawn,i;
    local vector loc;

    num=0;
    foreach AllActors(class'LavaFire',f,'FloorIsLavaFire'){
        num++;
    }

    numToSpawn = Min(MAX_LAVA_FIRE - num,25); //No more than 25 per tick

    if (numToSpawn<=0) return;

    num=0;
    for (i=0;i<(MAX_LAVA_FIRE*2) && num<numToSpawn;i++){ //Make double the number of fires of attempts to spawn them
        loc = class'LavaFire'.static.GetLocation(Player());
        if(loc != vect(0,0,0)) {
            Spawn(class'LavaFire', Level, 'FloorIsLavaFire', loc);
            num++;
        }
    }
}

function int GiveItem(string viewer, string type, optional int amount) {
    local int i;
    local class<Inventory> itemclass;
    local string outMsg;
    local Inventory item;
    local DXRLoadouts loadout;

    if( amount < 1 ) amount = 1;

    itemclass = class<Inventory>(ccLink.ccModule.GetClassFromString(type,class'Inventory'));

    if (itemclass == None) {
        return NotAvail;
    }

    //Check loadout for simulated effects or in case the selectability somehow failed
    loadout = DXRLoadouts(ccLink.dxr.FindModule(class'DXRLoadouts'));
    if (loadout!=None){
        if (loadout.is_banned(itemclass)){
            //This could possibly be available later in the session if they change loadouts
            return TempFail;
        }
    }

    for (i=0;i<amount;i++) {
        item = class'DXRActorsBase'.static.GiveItem(player(), itemclass);
        if( item == None ) return Failed;
    }

    outMsg = viewer@"gave you";
    if( amount > 1 && DeusExAmmo(item) != None ) {
        outMsg = outMsg @amount@"cases of"@item.ItemName;
    }
    else if( DeusExAmmo(item) != None ) {
        outMsg = outMsg @"a case of"@item.ItemName;
    }
    else if( amount > 1 ) {
        outMsg = outMsg @ amount @ item.ItemName $ "s";
    } else {
        outMsg = outMsg @ item.ItemArticle @ item.ItemName;
    }

    PlayerMessage(outMsg $ shouldSave);
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
    p = Spawn( c, GetCrowdControlPawn(viewer),,player().Location);
    if( p == None ) return Failed;
    PlayerMessage(viewer@"dropped "$ p.ItemArticle @ p.ItemName $ " at your feet!");
    p.Velocity.X=0;
    p.Velocity.Y=0;
    p.Velocity.Z=0;
    return Success;
}

function ScriptedPawn findOtherHuman(bool bAllowImportant) {
    local int num;
    local ScriptedPawn p;
    local ScriptedPawn humans[512];

    num = 0;

    foreach AllActors(class'ScriptedPawn',p) {
        if (class'DXRActorsBase'.static.IsHuman(p.class) && p!=player() && !p.bHidden && !p.bStatic && p.bInWorld && p.Orders!='Sitting' && !p.Region.Zone.IsA('SkyZoneInfo')) {
            if (!p.bImportant || bAllowImportant){
                humans[num++] = p;
            }
        }
    }

    if( num == 0 ) return None;
    return humans[ Rand(num) ];
}

function bool swapPlayer(string viewer) {
    local ScriptedPawn a;

    a = findOtherHuman(False);

    if (a == None) {
        return false;
    }

    if (ccLink.ccModule.Swap(player(),a)==false){
        return false;
    }

    player().ViewRotation = player().Rotation;
    PlayerMessage(viewer@"thought you would look better if you were where"@a.FamiliarName@"was");

    return true;
}

function doNudge(string viewer) {
    local Vector bobble,randVect;
    local float size;

    size = FRand() + 0.3;
    randVect=VRand();
    if (randVect.Z<0) randVect.Z*=-1; //Never bump downwards, only up
    randVect.Z*=0.5; //Don't get too vertically extreme

    bobble = vect(300.0,300.0,200.0) + 300.0 * size * randVect;

    //Peeling the player off the ground makes this much more potent
    if ( player().Physics == PHYS_Walking ){
        player().SetPhysics(PHYS_Falling);
    }

    player().Velocity += bobble;

    //Play an oof sound
    player().PlaySound(player().HitSound1);

    PlayerMessage(viewer@"nudged you a little bit");

}

function AskRandomQuestion(String viewer) {

    local string question;
    local string answers[3];
    local int numAnswers;

    ccLink.ccModule.getRandomQuestion(question,numAnswers,answers[0],answers[1],answers[2]);

    ccLink.ccModule.CreateCustomMessageBox(viewer$" asks...",question,numAnswers,answers,ccLink.ccModule,1,True);

}

function startEarthquake(float time) {
    local float shakeRollMagnitude,shakeTime,shakeVertMagnitude;

    shakeRollMagnitude = 2500.0;
    shakeTime = time;
    shakeVertMagnitude = 75.0;

    player().ShakeView(shakeTime,shakeRollMagnitude,shakeVertMagnitude);

}

function int Earthquake(String viewer, int duration) {

    startEarthquake(duration);

    PlayerMessage(viewer@"set off an earthquake!");

    return Success;

}

function int TriggerAllAlarms(String viewer) {
    local int numAlarms;
    local #var(prefix)AlarmUnit au;
    local SecurityCamera sc;
    local LaserTrigger lt;

    numAlarms = 0;

    foreach AllActors(class'#var(prefix)AlarmUnit',au){
        if (au.bDisabled) continue; //Skip disabled alarms
        if (au.bConfused) continue; //Skip confused alarms
        numAlarms+=1;
        au.Trigger(self,player());
    }
    foreach AllActors(class'SecurityCamera',sc){
        if (CCResidentEvilCam(sc)!=None){ continue; } //Skip Resident Evil cameras
        if (sc.bConfused) continue; //Skip Confused cameras
        if (!sc.bActive) continue; //Skip Deactivated cameras
        if (sc.bNoAlarm) continue; //Skip friendly cameras
        numAlarms+=1;
        sc.TriggerEvent(True);
        sc.bPlayerSeen=True;
        sc.lastSeenTimer=0;
    }
    foreach AllActors(class'LaserTrigger',lt){
        if (lt.bConfused){continue;}
        if (lt.bIsOn==False){continue;}
        if (lt.bNoAlarm){continue;}
        if (lt.AmbientSound!=None){continue;}
        numAlarms+=1;
        lt.BeginAlarm();
    }

    if (numAlarms==0){
        return TempFail;
    }

    PlayerMessage(viewer@"set off "$numAlarms$" alarms!");

    return Success;

}

function int SpawnNastyRat(string viewer)
{
    local vector spawnLoc;
    local NastyRat nr;
    local int num;

    //Only allow a certain number of nasty rats in each level
    foreach AllActors(class'NastyRat',nr){
        if (++num>=MAX_NASTY_RAT) {
            return TempFail;
        }
    }

    spawnLoc = ccLink.ccModule.GetRandomPositionFine(,2000,10000);

    nr = Spawn(class'NastyRat',,,spawnLoc);
    if (nr==None){
        return TempFail;
    }

    PlayerMessage(viewer@"had declared a war against rats...");
    if (ccLink.anon || ccLink.offline){
        class'DXRNames'.static.GiveRandomName(dxr, nr);
    } else {
        nr.UnfamiliarName = viewer;
        nr.FamiliarName = viewer;
    }

    return Success;
}

function int DropPiano(string viewer)
{
    #ifdef injections
    local #var(prefix)WHPiano piano;
    #else
    local DXRPiano piano;
    #endif
    local DXRActorsBase tracer;
    local vector loc;
    local rotator r;
    local float height, leading;
    local #var(PlayerPawn) p;
    local int num;

    num = 0;
    #ifdef injections
    foreach AllActors(class'#var(prefix)WHPiano',piano){
    #else
    foreach AllActors(class'DXRPiano',piano){
    #endif
        if (++num>=MAX_PIANOS) {
            return TempFail;
        }
    }
    piano=None;

    p = player();
    loc = p.Location;
    leading = FRand() * 0.75 + 0.25; // minimum of 25% leading means keep moving, maximum of 100% leading means you need to stop moving (or just sidestep lol)
    loc.X += p.Velocity.X * leading;
    loc.Y += p.Velocity.Y * leading;
    height = 800;
    tracer = DXRActorsBase(dxr.FindModule(class'DXRActorsBase'));
    if(tracer != None) {
        height = tracer.GetDistanceFromSurface(loc, loc+vect(0,0,800));
    }

    //Make sure it is far enough off the ground (at LEAST twice the height of the player)
    if (height < (2 * player().CollisionHeight)){
        return TempFail;
    }

    loc.Z += height;

    //Make sure there's a reasonable line of sight between the piano spawnpoint and the player
    if (!player().FastTrace(loc)){
        return TempFail;
    }

    r = ccLink.ccModule.GetRandomYaw(true); //Unseeded randomness

    #ifdef injections
    piano = Spawn(class'#var(prefix)WHPiano',,, loc, r);
    #else
    piano = Spawn(class'DXRPiano',,, loc, r);
    #endif
    //Did it spawn successfully?
    if(piano == None) {
        return TempFail;
    }

    //Make sure there's still a line of sight from where it actually spawned
    if (!piano.FastTrace(player().Location)){
        piano.Destroy(); //Pretend it never existed if there isn't
        return TempFail;
    }

    if(ccLink.ccModule.IsOctober()) {
        piano.ItemName = viewer $ "'s Staufway Piano";
    } else {
        piano.ItemName = viewer $ "'s Grand Piano";
    }

    piano.Velocity.Z -= 200;
    piano.Instigator = GetCrowdControlPawn(viewer);
    piano.FamiliarName = piano.ItemName;
    piano.UnfamiliarName = piano.FamiliarName;
    PlayerMessage(viewer$" dropped a piano on you from " $ int(class'DXRActorsBase'.static.GetRealDistance(height)) @ class'DXRActorsBase'.static.GetDistanceUnit() @ "with" @ int(leading*100 + 0.5)$"% leading!");
    return Success;
}

function int SpawnPawnNearPlayer(DeusExPlayer p, class<ScriptedPawn> newclass, bool friendly, string viewer)
{
    local int i;
    local ScriptedPawn n,o;
    local float radius;
    local vector loc, loc_offset;
    local rotator rot;
    local Inventory inv;
    local NanoKey k1, k2;

    if( p == None ) {
        err("p == None?");
        return TempFail;
    }

    if( newclass == None ) {
        err("newclass == None?");
        return Failed;
    }

    radius = p.CollisionRadius + newclass.default.CollisionRadius;
    for(i=0; i<10; i++) {
        loc_offset.X = 1 + FRand() * 3 * Sqrt(float(2));
        loc_offset.Y = 1 + FRand() * 3 * Sqrt(float(2));
        if( Rand(2)==0 ) loc_offset *= -1;

        loc = p.Location + (radius*loc_offset);

        if (friendly) {
            rot = Rotator(loc-p.Location); //Face friendlies away from the player
        } else {
            rot = Rotator(p.Location-loc); //Face enemies towards the player
        }

        n = Spawn(newclass,,, loc,rot);

        if( n != None ) break;
    }
    if( n == None ) {
        info("failed to spawn class "$newclass$" into "$loc);
        return TempFail;
    }
    info("spawning class "$newclass);

    PlayerMessage(viewer@"spawned a "$n.FamiliarName$" next to you!");

    //OBVIOUSLY they should get the viewer name instead of a random one if it's not in anonymous mode
    if (ccLink.anon || ccLink.offline){
        class'DXRNames'.static.GiveRandomName(dxr, n);
    } else {
        n.UnfamiliarName = viewer;
        n.FamiliarName = viewer;
    }

    if (friendly){
        n.Alliance = 'FriendlyCCSpawn';
        n.ChangeAlly('Player',1,True);
        n.ChangeAlly('HostileCCSpawn',-1,True);
        foreach AllActors(class'ScriptedPawn',o){
            if (o.GetPawnAllianceType(p)==ALLIANCE_Hostile){
                n.ChangeAlly(o.Alliance,-1,True);
            }
        }

        //This would be cool, but it seems like robots (at least) have no aggression to enemies if they are following
        //n.SetOrders('Following',,True);
    } else {
        n.Alliance = 'HostileCCSpawn';
        n.ChangeAlly('Player',-1,True);
        n.ChangeAlly('FriendlyCCSpawn',-1,True);
    }

    return Success;
}

function int NextHUDColorTheme(string viewer)
{
    local ColorTheme theme;

    //Find the next theme, and wrap around to the beginning if necessary
    theme=player().ThemeManager.GetNextThemeByType(player().ThemeManager.GetCurrentHUDColorTheme(),CTT_HUD);
    if (theme==None){
        theme=player().ThemeManager.GetFirstTheme(1); //1 is CTT_HUD, can't use the enum here
    }

    player().ThemeManager.SetCurrentHUDColorTheme(theme);
    DeusExRootWindow(player().rootWindow).ChangeStyle();
    player().HUDThemeName = player().ThemeManager.GetCurrentHUDColorTheme().GetThemeName();
    player().SaveConfig();

    PlayerMessage(viewer@"gave your game a fresh coat of paint ("$theme.GetThemeName()$")");

    return Success;
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

function bool CanSwapEnemies()
{
    local int numEnemies;
    local ScriptedPawn a;

    numEnemies=0;
    foreach AllActors(class'ScriptedPawn', a )
    {
        if( a.bHidden || a.bStatic ) continue;
        if( a.bImportant || a.bIsSecretGoal ) continue;
        if( !ccLink.ccModule.IsRelevantPawn(a.class) ) continue;
        if( !ccLink.ccModule.IsInitialEnemy(a) ) continue;
        if( a.Region.Zone.bWaterZone || a.Region.Zone.bPainZone ) continue;
        if( #var(prefix)Robot(a) != None && a.Orders == 'Idle' ) continue;
#ifdef gmdx
        if( SpiderBot2(a) != None && SpiderBot2(a).bUpsideDown ) continue;
#endif
        numEnemies++;
    }

    //As long as there are two possible enemies...
    return numEnemies > 1;
}

function bool SwapAllEnemies(string viewer)
{
    local DXREnemiesShuffle enemies;

    foreach AllActors(class'DXREnemiesShuffle',enemies){break;}

    if (enemies==None) return False; //Failed to find DXREnemiesShuffle

    enemies.SwapScriptedPawns(100,true);

    PlayerMessage(viewer@"swapped the position of all the enemies in the level!");

    return true;
}

function bool CanSwapItems()
{
    local int numItems;
    local Inventory inv;

    numItems=0;
    foreach AllActors(class'Inventory',inv){
        if (!ccLink.ccModule.SkipActor(inv)){
            numItems++;
        }
    }

    return numItems>1;
}

function bool SwapAllItems(string viewer)
{
    ccLink.ccModule.SwapAll("Engine.Inventory",100);

    PlayerMessage(viewer@"swapped the position of all the inventory items in the level!");

    return true;
}

function bool ToggleFlashlight(string viewer)
{
    local Augmentation aug;

    aug = player().AugmentationSystem.FindAugmentation(class'#var(prefix)AugLight');

    if (aug==None) return False;

    if (aug.IsActive()){
        aug.Deactivate();
    } else {
        aug.Activate();
    }

    PlayerMessage(viewer@"toggled your flashlight!");

    return true;

}

function int GiveAllEnemiesWeapon(class<#var(DeusExPrefix)Weapon> w,string viewer)
{
    local int numEnemies;
    local inventory inv;
    local ScriptedPawn a;

    numEnemies=0;

    foreach AllActors(class'ScriptedPawn', a )
    {
        if( a.bHidden || a.bStatic ) continue;
        if( #var(prefix)Animal(a)!=None ) continue;
        if( #var(prefix)Robot(a) != None ) continue;
        if( !ccLink.ccModule.IsInitialEnemy(a) ) continue;
        numEnemies++;
        inv = ccLink.ccModule.GiveItem(a,w,1);
    }

    if (numEnemies==0){
        return TempFail;
    }

    PlayerMessage(viewer@"gave "$numEnemies$" enemies a "$inv.ItemName$"!");

    return Success;
}

function bool HealAllEnemies(string viewer)
{
    local int numEnemies;
    local ScriptedPawn a;

    numEnemies=0;

    foreach AllActors(class'ScriptedPawn', a )
    {
        if( a.bHidden || a.bStatic ) continue;
        if( #var(prefix)Animal(a)!=None ) continue;
        if( #var(prefix)Robot(a) != None ) continue;
        if( !ccLink.ccModule.IsInitialEnemy(a) ) continue;
        if ( a.IsInState('Dying') ) continue; //It's too late for this guy...
        if ( a.bInvincible ) continue;
        if ( a.Health >= a.Default.Health ) continue; //Nothing to heal

        numEnemies++;
        a.Health         = a.Default.Health;
        a.HealthArmLeft  = a.Default.HealthArmLeft;
        a.HealthArmRight = a.Default.HealthArmRight;
        a.HealthLegLeft  = a.Default.HealthLegLeft;
        a.HealthLegRight = a.Default.HealthLegRight;
        a.HealthHead     = a.Default.HealthHead;
        a.HealthTorso    = a.Default.HealthTorso;

        if (a.bOnFire){
            a.ExtinguishFire();
        }

        //Get back in the fight, soldier!
        if (a.IsInState('Fleeing') || a.IsInState('Burning') || a.IsInState('RubbingEyes')){
            a.FearLevel=0;
            a.FollowOrders();
        }
    }

    if (numEnemies==0){
        return False;
    }

    PlayerMessage(viewer@"healed "$numEnemies$" enemies to full health!");

    return True;
}

function bool RaiseDead(string viewer)
{
    local #var(DeusExPrefix)Carcass carc;
    local int num,i;

    num=0;

    for (i=0;i<5;i++){
        carc = FindClosestCarcass(1000,false,true);
        if (carc==None){
            break;
        }
        if (class'DXRZombies'.static.ReanimateCorpse(ccLink.ccModule, carc, viewer $ "'s Zombie")){
            num++;
        }
    }

    if (num==0){
        return False;
    }

    PlayerMessage(viewer@"rose "$num$" from the dead!");

    return True;
}

function bool CorpseExplosion(string viewer)
{
    local #var(DeusExPrefix)Carcass carc;
    local int num,i;
    local DXRandoCrowdControlPawn viewerPawn;

    viewerPawn = GetCrowdControlPawn(viewer);
    num=0;

    for (i=0;i<5;i++){
        carc = FindClosestCarcass(1000,true,false);
        if (carc==None){
            break;
        }
        carc.Instigator = viewerPawn;
        DetonateCarcass(carc);
        num++;
    }

    if (num==0){
        return False;
    }

    PlayerMessage(viewer@"detonated "$num$" corpses!");

    return True;

}

function #var(DeusExPrefix)Carcass FindClosestCarcass(float radius, optional bool bAllowAnimals, optional bool bAllowInvincible)
{
    local #var(DeusExPrefix)Carcass carc,closest;
    local float closeDist;

    closest = None;
    closeDist = 2 * radius;
    foreach player().RadiusActors(class'#var(DeusExPrefix)Carcass',carc,radius){
        if (carc.bNotDead){
            continue; //Skip unconscious bodies
        }
        if (!bAllowInvincible && carc.bInvincible){
            continue; //Skip invincible bodies (Paul's corpse in M05)
        }
        if (!bAllowAnimals && carc.bAnimalCarcass){
            continue;
        }
        if (VSize(carc.Location-player().Location) < closeDist){
            closest = carc;
            closeDist = VSize(carc.Location-player().Location);
        }
    }

    return closest;
}

//Duped from MIB
function DetonateCarcass(#var(DeusExPrefix)Carcass carc)
{
    local SphereEffect sphere;
    local ScorchMark s;
    local ExplosionLight light;
    local int i;
    local float explosionDamage;
    local float explosionRadius;

    explosionDamage = 100;
    explosionRadius = 256;

    // alert NPCs that I'm exploding
    AISendEvent('LoudNoise', EAITYPE_Audio, , explosionRadius*16);
    PlaySound(Sound'LargeExplosion1', SLOT_None,,, explosionRadius*16);

    // draw a pretty explosion
    light = Spawn(class'ExplosionLight',,, carc.Location);
    if (light != None)
        light.size = 4;

    Spawn(class'ExplosionSmall',,, carc.Location + 2*VRand()*carc.CollisionRadius);
    Spawn(class'ExplosionMedium',,, carc.Location + 2*VRand()*carc.CollisionRadius);
    Spawn(class'ExplosionMedium',,, carc.Location + 2*VRand()*carc.CollisionRadius);
    Spawn(class'ExplosionLarge',,, carc.Location + 2*VRand()*carc.CollisionRadius);

    sphere = Spawn(class'SphereEffect',,, carc.Location);
    if (sphere != None)
        sphere.size = explosionRadius / 32.0;

    // spawn a mark
    s = spawn(class'ScorchMark', carc.Base,, carc.Location-vect(0,0,1)*carc.CollisionHeight, carc.Rotation+rot(16384,0,0));
    if (s != None)
    {
        s.DrawScale = FClamp(explosionDamage/30, 0.1, 3.0);
        s.ReattachDecal();
    }

    // spawn some rocks and flesh fragments
    for (i=0; i<explosionDamage/4; i++)
    {
        if (FRand() < 0.2)
            spawn(class'Rockchip',,,carc.Location);
        else
            spawn(class'FleshFragment',,,carc.Location);
    }

    carc.HurtRadius(explosionDamage, explosionRadius, 'Exploded', explosionDamage*100, carc.Location);

    carc.Destroy();
}

function PlayerRadiates()
{
    local ScriptedPawn sp;

    //Radiate the same as a default gray - 10 damage per second in a 256 radius
    foreach player().VisibleActors(class'ScriptedPawn', sp, 256)
        sp.TakeDamage(10, player(), sp.Location, vect(0,0,0), 'Radiation');

}


function bool DropMarbles(string viewer)
{
    local DXRMarble ball;
    local int num,i;


    num = 0;
    foreach AllActors(class'DXRMarble',ball){
        if (++num>=MAX_MARBLES) {
            return False;
        }
    }

    ball=None;
    num=0;
    for (i=0;i<10;i++){
        ball = Spawn(class'DXRMarble',,,player().Location+vect(0,0,80),player().Rotation);
        if (ball!=None){
            ball.Velocity = vector(ball.Rotation) * 300 + vect(0,0,220) + VRand()*320;
            ball.Velocity.Z = abs(ball.Velocity.Z);
            ball.SetSkin(Rand(16));
            num++;
        }
    }

    if (num==0){
        return False;
    }

    PlayerMessage(viewer@"made you drop your marbles!");

    return True;
}

function string RandomSpamDatacubeText(String viewer)
{
    switch(Rand(26)){
        case 0:   return "Enlarge your Dragon Tooth!  Contact "$viewer$" Corp. for more details on how YOU can gain 4 inches TODAY!";
        case 1:   return "You've won the Gray Death vaccine lottery!  As thanks for signing up for more information on any vaccine news, you have won 1000 credits!  For more details, please send your full name, date of birth, occupation, drivers license, and 5000 credits to "$viewer$"!";
        case 2:   return "Your NYCNet account has violated security policies and will be deleted in three (3) days!  If you would like to keep your account, please send a picture of your ID as well as your mothers maiden name to "$viewer$" to prove your innocence.  Revalidating your account will cost a minimum fee of 12000 credits.";
        case 3:   return "Please update your payment details.  Your account with Classic Movies is missing information and may be locked if not provided within one (1) week.  Please respond to "$viewer$" for more details.";
        case 4:   return "You have been been selected as the lucky winner of the Nuka Cola online draw!  Contact "$viewer$" for more information on how to claim your lifetime supply.|n|n|n|n(Lifetime is defined as 1 year under current conditions)";
        case 5:   return "Register for YOUR opportunity to receive the Gray Death vaccine NOW!  Don't miss your shot, this is a first-come, first-served offer!  Send your information to "$viewer$" to get in line RIGHT NOW!";
        case 6:   return "You are a FOOL!|n|n-"$viewer;
        case 7:   return "ICARUS HAS FOUND YOU... And wants to offer you an exclusive vacation offer to visit beautiful Paris!  Please contact your closest MJ12 associate ("$viewer$") to set up your vacation today!";
        case 8:   return "Your package from "$viewer$" has been delivered to the 'Ton Hotel!  Please come to pick it up promptly, as it may be returned otherwise.  This package requires a payment of 7500 credits before being handed off.";
        case 9:   return "I have been watching and recording you through your Infolink and I know EVERYTHING that you've done.  If you want to keep this information private from your brother, Paul, you will need to send 400 PageCoins to the digital wallet held under the name "$viewer$".  If you do not pay within three (3) days, these videos will be sent to Paul.";
        case 10:  return "Free guitar lessons!  Please contact "$viewer$" to set up a lesson today!";
        case 11:  return "Lost dog!|n|nHave you seen my dog?  They might respond to the name "$viewer$" but honestly I never did much training, so no guarantees!  Help PLEASE!";
        case 12:  return "15% off all drinks at the Underworld Tavern!  Tell the bartender "$viewer$" sent you!";
        case 13:  return "Do you want to be your own boss?  Do you want to have additional revenue streams?  Do you want to grow your own business?  Attend a presentation this weekend by "$viewer$" to learn about the amazing possibilities!";
        case 14:  return "Wow, Crowd Control sure is neat!  At least, "$viewer$" certainly seems to think so!";
        case 15:  return "Mechanical augmentations got you down?  Need your latest dose of neuropozyne but don't have the credits to get it?  Buy cheap Nu-Poz from the Canadian "$viewer$" Online Pharmacy today!  Prices are less than half what you might pay in your local pharmacy!";
        case 16:  return "Hi.  I want to offer promotion of your channel, viewers, followers, views, chat bots.  The price is lower than any competitor, the quality is guaranteed to be the best."$"  Auto-in.  Incredibly flexible and convenient order management panel, everything is in your hands, turn it on/off/customize.  Go to "$viewer$" dot com";
        case 17:  return "Hi, this is "$viewer$".  It seems you are a beginner.  I can improve the appearance of your channel with awesome ideas that would give your channel a professional look."$"  I have been a professional artist and graphic designer for over a decade, and designed my own graphics for said stream";
        case 18:  return "We've been trying to reach you concerning your vehicle's extended warranty.  You should've received a notice in the mail about your car's extended warranty eligibility."$"  Since we've not gotten a response, we're giving you a final courtesy datacube before we close out your file.  Please contact "$viewer$" to learn more about possibly extending or reinstating your vehicle's warranty.";
        case 19:  return "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.  Ut enim ad minim veniam,"$" quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.  Duis aute irure dolor in reprehenderit in voluptate"$" velit esse cillum dolore eu fugiat nulla pariatur.  Excepteur sint occaecat cupidatat non"$" proident, sunt in culpa qui officia deserunt mollit anim id est laborum.|n|n  -"$viewer;
        case 20:  return "hi every1 im new!!!!!!! *holds up spork* my name is "$viewer$" but u can call me t3h PeNgU1N oF d00m!!!!!!!! lol...as u can see im very random!!!!"$" thats why i came here, 2 meet random ppl like me ^_^... im 13 years old (im mature 4 my age tho!!) i like 2 watch invader zim w/ my girlfreind"$" (im bi if u dont like it deal w/it) its our favorite tv show!!! bcuz its SOOOO random!!!! shes random 2 of course but i want 2 meet more random ppl =) "$"like they say the more the merrier!!!! lol...neways i hope 2 make alot of freinds here "$"so give me lots of commentses!!!!|nDOOOOOMMMM!!!!!!!!!!!!!!!! <--- me bein random again ^_^ hehe...toodles!!!!!"$"|n|nlove and waffles,|n|nt3h PeNgU1N oF d00m";
        case 21:  return viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer$" "$viewer;
        case 22:  return viewer$" has a document for your review|n------------------------------------------------------|n|n  "$viewer$" has shared a document with you:|n|n        <invoice.pdf>|n|n|nClick here to open";
        case 23:  return "Your password changed|n|nYour password for your account "$viewer$"@NYCNet was changed.|n|nIf this was you, then you can safely ignore this datacube.|n|n|nIf this wasn't you, your account has been compromised.  Please follow these steps"$"|n1) Reset your password|n2) Review your security info|n3) Learn how to make your account more secure."$"|n|nYou can also opt out or change where you receive security notifications.|n|nThanks,|nThe NYCNet account team";
        case 24:  return "Fed-UPS Failed Delivery Attempt|n|nDear "$viewer$",|n|nWe have attempted to deliver your item!"$"|n|nThe delivery attempt failed because nobody was present at the shipping address, so this datacube has been automatically sent.  "$"You may arrange re-delivery by visiting the nearest Fed-UPS office with the printed shipping invoice mentioned below."$"|n|nIf the package is not scheduled for delivery or picked up within 48 hours, it will be returned to the sender.|n|n<invoice.pdf>";
        case 25:  return "Hello Dear,|nI am "$viewer$", the widow of the Late Nigerian Head of State.  I am presently in distress and under house arrest while my son is undergoing trial,"$" though he has just been recently granted bail under the condition that my family refunds to the Federal Government some amount of money.  "$"The government has frozen all the family account and auctioned all our properties.  Refer to this website about my husband's loot and you will understand what I mean.|n"$"To save the family from total bankruptcy I have managed to ship through an undercover courier company, the sum of 6.5 Billion Credits, kept by my late partner.  "$"The money was disguised to beat the Nigerian Security and it is currently deposited in a security company which I will disclose the name and contacts to you if I get a positive response from you.  "$"I want you to receive the money and pay into your account for the family safely.  I am offering you 30% for assisting me secure this money"$"  Contact me immediately with my email address so that I can forward to you all necessary details.  "$"Endeavor to send your phone and fax numbers for easy Communications.  This project is not risky.|nBest Regards.|n"$viewer;
    }

    return "SOMEHOW FAILED TO GENERATE SPAM MESSAGE FOR "$viewer$" SO ENJOY THIS COMPLIMENTARY ERROR DATACUBE INSTEAD";
}

function bool SpamDatacubes(String viewer)
{
    local int num,i;
    local #var(injectsprefix)InformationDevices dc;

    num = 0;
    foreach AllActors(class'#var(injectsprefix)InformationDevices',dc,'CrowdControlSpamDatacube'){
        if (++num>=MAX_SPAM_CUBES) {
            return False;
        }
    }

    dc = None;
    num = 0;
    for (i=0;i<5;i++){
        dc = ccLink.ccModule.SpawnDatacubePlaintext(ccLink.ccModule.GetRandomPositionFine(),rot(0,0,0),RandomSpamDatacubeText(viewer),"");
        if (dc!=None){
            dc.Tag='CrowdControlSpamDatacube';
            ccLink.ccModule.GlowUp(dc);
            num++;
        }
    }
    if (num==0){
        return False;
    }

    PlayerMessage(viewer@"dropped off "$num$" advertising datacubes!");

    return True;
}

function bool BloodForTheBloodGod()
{
    local #var(PlayerPawn) p;
    local #var(prefix)ScriptedPawn sp;
    local int num;

    num=0;

    foreach AllActors(class'#var(prefix)ScriptedPawn',sp){
        if (sp.bCanBleed){
            HandleSingleBloodGodSacrifice(sp);
            num++;
        }
    }

    foreach AllActors(class'#var(PlayerPawn)',p){
        HandleSingleBloodGodSacrifice(p);
        num++;
    }

    return num>0;
}

function bool RandomClothes()
{
#ifndef vmd
    local DXRFashionManager fashion;

    fashion = class'DXRFashionManager'.static.GiveItem(player());

    if (fashion==None) return False; //Shouldn't happen, but might as well be sure of it

    fashion.RandomizeClothes(player());
    fashion.GetDressed();

    return True;
#endif
}

function int ShuffleBelt(String viewer)
{
    local int i,slot;
    local #var(PlayerPawn) p;
    local DeusExRootWindow root;
    local Inventory beltItems[9],origBelt[9];
    local Inventory invTemp;
    local bool worked;

    p = Player();

    if (p==None){
        return TempFail;
    }

    root = DeusExRootWindow(p.rootWindow);

    if (root==None){
        return TempFail;
    }

    //Items are in slots 1-9, Keyring is in 0
    for(i=0;i<9;i++){
        beltItems[i]=root.hud.belt.GetObjectFromBelt(i+1);
        origBelt[i]=beltItems[i];
        //p.ClientMessage("Belt "$(i+1)$": "$beltItems[i]);
        worked=True;
    }

    //Don't continue unless the player has *something* in their belt
    if (!worked){
        return TempFail;
    }

    //Shuffle the items
    worked=False;
    for(i=0;i<9;i++){
        slot=Rand(9);

        if (slot==i) continue; //Don't swap with self
        if (beltItems[i]==None && beltItems[slot]==None) continue; //Don't swap if both are empty

        invTemp=beltItems[i];
        beltItems[i]=beltItems[slot];
        beltItems[slot]=invTemp;

        worked=True;

    }

    //Don't continue if it didn't actually shuffle anything
    if (!worked){
        return TempFail;
    }

    //Compare new shuffled belt to original belt
    worked=False;
    for (i=0;i<9;i++){
        if (beltItems[i]!=origBelt[i]) {
            worked=True;
            break;
        }
    }

    //Don't continue if the shuffling ended with the same layout as before shuffling (really bad luck)
    if (!worked){
        return TempFail;
    }

    //Success!
    //Assign the items to their new slots
    for(i=0;i<9;i++){
        if (beltItems[i]!=None){
            root.hud.belt.RemoveObjectFromBelt(beltItems[i]);
            root.hud.belt.AddObjectToBelt(beltItems[i],i+1,True);
        }
    }
    root.hud.belt.PopulateBelt();

    PlayerMessage(viewer@"shuffled your item belt!");

    return Success;
}

function HandleSingleBloodGodSacrifice(Actor a)
{
    if (Rand(4)==0){
        SpawnBloodDrop(a);
    }
    if (Rand(25)==0){
        SpawnBloodPool(a);
    }
}

//Logic copied from DeusExCarcass HandleLanding()
function SpawnBloodPool(Actor a)
{
    local BloodPool bp;
    local Vector HitLocation, HitNormal, EndTrace;
    local Actor hit;

    if (a.Region.Zone.bWaterZone){
        return; //Don't spawn blood pools if you're in the water
    }

    // trace down about 20 feet if we're not in water
    EndTrace = a.Location - vect(0,0,320);
    hit = Trace(HitLocation, HitNormal, EndTrace, a.Location, False);

    bp = spawn(class'BloodPool',,, HitLocation+HitNormal, Rotator(HitNormal));
    if (bp!=None){
        bp.maxDrawScale = a.CollisionRadius / 40.0;
    }
}

//Copied from ScriptedPawn SpurtBlood with slight modification
function SpawnBloodDrop(Actor a)
{
    local vector bloodVector;
    local float offset;

    offset = (FRand() * 0.5) + 0.25; //Height between 0.25 and 0.75

    bloodVector = vect(0,0,1)*a.CollisionHeight*offset;  // so folks don't bleed from the crotch
    spawn(Class'BloodDrop',,,bloodVector+a.Location);
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

simulated final function #var(PlayerPawn) player()
{
    return dxr.flags.player();
}

//#endregion



/////////////////////////////////////////////////////////////////////////////////////////////////////////////
////                                  CROWD CONTROL EFFECT MAPPING                                       ////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
//#region Msg Type Split
function int BranchCrowdControlType(string code, string param[5], string viewer, int type, int duration) {
    local int result;

    switch (type){
        case CCType_Start:
            result = doCrowdControlEvent(code,param,viewer,type,duration);

            if (result == Success) {
                ccLink.ccModule.IncHandledEffects();
            }
            break;
        case CCType_Stop:
            if (code==""){
                //Stop all
                StopAllCrowdControlEvents();
            } else {
                //Stop specific effect
                result = StopCrowdControlEvent(code);
            }
            break;
        default:
            result = Failed;
            break;
    }

    return result;
}
//#endregion

//#region Stop All Events
//Make sure to add any timed effects into this list
function StopAllCrowdControlEvents()
{
    StopCrowdControlEvent("disable_jump");
    StopCrowdControlEvent("gotta_go_fast"); //also gotta_go_slow
    StopCrowdControlEvent("emp_field");
    StopCrowdControlEvent("matrix");
    StopCrowdControlEvent("third_person");
    StopCrowdControlEvent("ice_physics");
    StopCrowdControlEvent("floaty_physics");
    StopCrowdControlEvent("floor_is_lava");
    StopCrowdControlEvent("invert_mouse");
    StopCrowdControlEvent("invert_movement");
    StopCrowdControlEvent("earthquake");
    StopCrowdControlEvent("lamthrower");
    StopCrowdControlEvent("dmg_double"); //also dmg_half
    StopCrowdControlEvent("barrel_roll"); //also flipped and limp_neck
    StopCrowdControlEvent("eat_beans");
    StopCrowdControlEvent("resident_evil");
    StopCrowdControlEvent("radioactive");
    StopCrowdControlEvent("doom_mode");
    StopCrowdControlEvent("wine_bullets");
    StopCrowdControlEvent("blood_god");
}
//#endregion

//#region Stop CC Event
function int StopCrowdControlEvent(string code, optional bool bKnownStop)
{
    switch(code) {
        case "disable_jump":
            if (bKnownStop || isTimerActive('cc_JumpTimer')){
                player().JumpZ = player().Default.JumpZ;
                PlayerMessage("Your knees feel fine again.");
                disableTimer('cc_JumpTimer');
            }
            break;
        case "gotta_go_fast":
        case "gotta_go_slow":
            if (bKnownStop || isTimerActive('cc_SpeedTimer')){
                player().Default.GroundSpeed = DefaultGroundSpeed;
                PlayerMessage("Back to normal speed!");
                disableTimer('cc_SpeedTimer');
            }
            break;
        case "emp_field":
            if (bKnownStop || isTimerActive('cc_EmpTimer')){
                player().bWarrenEMPField = false;
                PlayerMessage("EMP Field has disappeared...");
                disableTimer('cc_EmpTimer');
            }
            break;
        case "matrix":
            if (bKnownStop || isTimerActive('cc_MatrixModeTimer')){
                StopMatrixMode();
                disableTimer('cc_MatrixModeTimer');
            }
            break;
        case "third_person":
            if (bKnownStop || isTimerActive('cc_behindTimer')){
                dxrCameras.DisableTempCamera();
                PlayerMessage("You re-enter your body");
                disableTimer('cc_behindTimer');
            }
            break;
        case "ice_physics":
            if (bKnownStop || isTimerActive('cc_iceTimer')){
                SetIcePhysics(False);
                PlayerMessage("The ground thaws");
                disableTimer('cc_iceTimer');
            }
            break;
        case "floaty_physics":
            if (bKnownStop || isTimerActive('cc_floatyTimer')){
                SetFloatyPhysics(False);
                PlayerMessage("You feel weighed down again");
                disableTimer('cc_floatyTimer');
            }
            break;
        case "floor_is_lava":
            if (bKnownStop || isTimerActive('cc_floorLavaTimer')){
                DestroyAllLavaFire();
                PlayerMessage("The floor returns to normal temperatures");
                disableTimer('cc_floorLavaTimer');
            }
            break;
        case "invert_mouse":
            if (bKnownStop || isTimerActive('cc_invertMouseTimer')){
                PlayerMessage("Your mouse controls return to normal");
                player().bInvertMouse = bool(datastorage.GetConfigKey('cc_InvertMouseDef'));
                disableTimer('cc_invertMouseTimer');
            }
            break;
        case "invert_movement":
            if (bKnownStop || isTimerActive('cc_invertMovementTimer')){
                PlayerMessage("Your movement controls return to normal");
                invertMovementControls();
                disableTimer('cc_invertMovementTimer');
            }
            break;
        case "earthquake":
            if (bKnownStop || isTimerActive('cc_Earthquake')){
                PlayerMessage("The earthquake ends");
                player().shaketimer=0;
                disableTimer('cc_Earthquake');
            }
            break;
        case "lamthrower":
            if (bKnownStop || isTimerActive('cc_lamthrowerTimer')){
                UndoLamThrowers();
                PlayerMessage("Your flamethrower is boring again");
                disableTimer('cc_lamthrowerTimer');
            }
            break;
        case "dmg_double":
        case "dmg_half":
            if (bKnownStop || isTimerActive('cc_DifficultyTimer')){
                storeFloatValue('cc_damageMult',1.0);
                PlayerMessage("Your body returns to its normal toughness");
                disableTimer('cc_DifficultyTimer');
            }
            break;
        case "flipped":
        case "limp_neck":
        case "barrel_roll":
            if (bKnownStop || isTimerActive('cc_RollTimer')){
                PlayerMessage("Your world turns rightside up again");
                datastorage.SetConfig('cc_cameraRoll',0, 3600*12);
                datastorage.SetConfig('cc_cameraSpin',0, 3600*12);
                disableTimer('cc_RollTimer');
            }
            break;
        case "eat_beans":
            if (bKnownStop || isTimerActive('cc_EatBeans')){
                PlayerMessage("Your stomach settles down");
                disableTimer('cc_EatBeans');
            }
            break;
        case "resident_evil":
            if (bKnownStop || isTimerActive('cc_ResidentEvil')){
                PlayerMessage("Everything feels less horrifying");
                dxrCameras.DisableTempCamera();
                disableTimer('cc_ResidentEvil');
            }
            break;
        case "radioactive":
            if (bKnownStop || isTimerActive('cc_Radioactive')){
                PlayerMessage("You stop being radioactive");
                disableTimer('cc_Radioactive');
            }
            break;
        case "doom_mode":
            if (bKnownStop || isTimerActive('cc_DoomMode')){
                PlayerMessage("You return to the normal world");
                disableTimer('cc_DoomMode');
            }
            break;
        case "wine_bullets":
            if (bKnownStop || isTimerActive('cc_WineBullets')){
                PlayerMessage("Bullets are no longer coated in wine!");
                datastorage.SetConfig('cc_WineBullets',0, 3600*12);
                disableTimer('cc_WineBullets');
            }
            break;
        case "blood_god":
            if (bKnownStop || isTimerActive('cc_BloodGod')){
                PlayerMessage("The Blood God's thirst has been slaked!");
                datastorage.SetConfig('cc_BloodGod',0, 3600*12);
                disableTimer('cc_BloodGod');
            }


    }

    return Success;
}
//#endregion

//#region Handle Event
function int doCrowdControlEvent(string code, string param[5], string viewer, int type, int duration) {
    local int i;
    local ColorTheme theme;

    //Effects can't start on the title screen
    if (dxr.OnTitleScreen()){
        return TempFail;
    }

    switch(code) {
        case "poison":
            if (!InGame()) {
                return TempFail;
            }

            player().StartPoison(GetCrowdControlPawn(viewer),5);
            PlayerMessage(viewer@"poisoned you!");
            break;

        case "kill":
            if (!InGame()) {
                return TempFail;
            }

            player().Died(GetCrowdControlPawn(viewer),'CrowdControl',player().Location);
            PlayerMessage(viewer@"set off your killswitch!");
            class'DXRBigMessage'.static.CreateBigMessage(player(), None, viewer$" triggered your kill switch!", "");

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
            i =  Int(param[0]) * 10;
            player().HealPlayer(i,False);
            PlayerMessage(viewer@"gave you "$i$" health!" $ shouldSave);
            break;

        case "set_fire":
            player().CatchFire(GetCrowdControlPawn(viewer));
            PlayerMessage(viewer@"set you on fire! Hopefully you have a fire extinguisher.");
            break;

        case "full_heal":
            if (player().Health == 100) {
                return TempFail;
            }
            player().RestoreAllHealth();
            PlayerMessage(viewer@"fully healed you!" $ shouldSave);
            break;

        case "disable_jump":
            if (player().JumpZ == 0) {
                return TempFail;
            }

            player().JumpZ = 0;
            startnewTimer('cc_JumpTimer',duration);
            PlayerMessage(viewer@"made your knees lock up.");
            break;

        case "gotta_go_fast":
            if (DefaultGroundSpeed != player().Default.GroundSpeed) {
                return TempFail;
            }
            storeFloatValue('cc_moveSpeedModifier',MoveSpeedMultiplier);
            player().Default.GroundSpeed = DefaultGroundSpeed * moveSpeedMultiplier;
            startNewTimer('cc_SpeedTimer',duration);
            PlayerMessage(viewer@"made you fast like Sonic!");
            break;

        case "gotta_go_slow":
            if (DefaultGroundSpeed != player().Default.GroundSpeed) {
                return TempFail;
            }
            storeFloatValue('cc_moveSpeedModifier',MoveSpeedDivisor);
            player().Default.GroundSpeed = DefaultGroundSpeed * moveSpeedDivisor;
            startNewTimer('cc_SpeedTimer',duration);
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
            if (player().InHand == None && player().CarriedDecoration==None) {
                return TempFail;
            }

            if (player().InHand!=None){
                if (canDropItem() == False) {
                    return TempFail;
                }

                if (player().DropItem() == False) {
                    return TempFail;
                }
            } else if (player().CarriedDecoration!=None){
                player().DropDecoration(); //Doesn't return anything

                //But we can check if your hands are empty afterwards...
                if (player().CarriedDecoration!=None){
                    //Didn't drop
                    return TempFail;
                }
            }

            PlayerMessage(viewer@"made you fumble your item");
            break;

        case "emp_field":
            if (isTimerActive('cc_EmpTimer')) {
                return TempFail;
            }
            player().bWarrenEMPField = true;
            startNewTimer('cc_EmpTimer',duration);
            PlayerMessage(viewer@"made electronics allergic to you");
            break;

        case "matrix":
            if (player().Sprite!=None) {
                //Matrix Mode already enabled
                return TempFail;
            }
            StartMatrixMode();
            startNewTimer('cc_MatrixModeTimer',duration);
            PlayerMessage(viewer@"thinks you are The One...");
            break;

        case "third_person":
            if (isTimerActive('cc_behindTimer')) {
                return TempFail;
            }
            if (isTimerActive('cc_ResidentEvil')) {
                return TempFail;
            }
            dxrCameras.EnableTempThirdPerson();

            startNewTimer('cc_behindTimer',duration);
            PlayerMessage(viewer@"gave you an out of body experience");
            break;

        case "give_energy":

            if (player().Energy == player().EnergyMax) {
                return TempFail;
            }
            //Copied from BioelectricCell

            //PlayerMessage("Recharged 10 points");
            player().PlaySound(sound'BioElectricHiss', SLOT_None,,, 256);
            i = Int(param[0])*10;
            player().Energy += i;
            if (player().Energy > player().EnergyMax)
                player().Energy = player().EnergyMax;

            PlayerMessage(viewer@"gave you "$i$" energy!" $ shouldSave);
            break;

        case "give_full_energy":

            if (player().Energy == player().EnergyMax) {
                return TempFail;
            }
            //Copied from BioelectricCell

            //PlayerMessage("Recharged 10 points");
            player().PlaySound(sound'BioElectricHiss', SLOT_None,,, 256);
            player().Energy = player().EnergyMax;

            PlayerMessage(viewer@"refilled your energy!" $ shouldSave);
            break;

        case "give_skillpoints":
            i = Int(param[0])*100;
            PlayerMessage(viewer@"gave you "$i$" skill points" $ shouldSave);
            player().SkillPointsAdd(i);
            //Don't add to the total.  It isn't used in the base game, but we use it for scoring.
            //These points were not gained naturally, so don't count them towards your score
            player().SkillPointsTotal-=i; //Undo adding the skill points to your total
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

        case "ice_physics":
            if (isTimerActive('cc_iceTimer')) {
                return TempFail;
            }
            PlayerMessage(viewer@"made the ground freeze!");
            SetIcePhysics(True);
            startNewTimer('cc_iceTimer',duration);

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
                return TempFail;
            }
            break;

        case "swap_enemies":
            if (!InGame()) {
                return TempFail;
            }
            if (!CanSwapEnemies()){
                return TempFail;
            }
            if (SwapAllEnemies(viewer) == false) {
                return TempFail;
            }
            break;

        case "swap_items":
            if (!InGame()) {
                return TempFail;
            }
            if (!CanSwapItems()){
                return TempFail;
            }
            if (SwapAllItems(viewer) == false) {
                return TempFail;
            }
            break;

        case "floaty_physics":
            if (isTimerActive('cc_floatyTimer')) {
                return TempFail;
            }
             //Floaty physics can interrupt conversations
             //which can result in keys not getting transferred
             //or flags not getting set right.  Just don't allow it.
            if (InConversation()){
                return TempFail;
            }

            //Don't start floaty physics if you're in the water.  It works,
            //but it's janky (even if I fixed it ending in the water)
            if (player().Region.Zone.bWaterZone){
                return TempFail;
            }

            PlayerMessage(viewer@"made you feel light as a feather");
            SetFloatyPhysics(True);
            startNewTimer('cc_floatyTimer',duration);

            break;

        case "floor_is_lava":
            if (!InGame()) {
                return TempFail;
            }
            if (isTimerActive('cc_floorLavaTimer')){
                return TempFail;
            }
            PlayerMessage(viewer@"turned the floor into lava! Keep jumping or find something safe to stand on.");
            lavaTick = 0;
            startNewTimer('cc_floorLavaTimer',duration);
            setFloorIsLavaName(viewer);

            break;

        case "invert_mouse":
            if (!InGame()) {
                return TempFail;
            }
            if (isTimerActive('cc_invertMouseTimer')){
                return TempFail;
            }
            PlayerMessage(viewer@"inverted your mouse!");
            datastorage.SetConfig('cc_InvertMouseDef',player().bInvertMouse, 3600*12);

            player().bInvertMouse = !player().bInvertMouse;
            startNewTimer('cc_invertMouseTimer',duration);

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

            startNewTimer('cc_invertMovementTimer',duration);
            break;

        case "earthquake":
            if (!InGame()) {
                return TempFail;
            }
            if (isTimerActive('cc_Earthquake')){
                return TempFail;
            }

            startnewTimer('cc_Earthquake',duration);

            return Earthquake(viewer,duration);

        case "trigger_alarms":
            if (!InGame()) {
                return TempFail;
            }

            return TriggerAllAlarms(viewer);



        // LAM Thrower crashes for mods with fancy physics?
        case "lamthrower":
            if (!#defined(vanilla)){
                PlayerMessage("LAMThrower effect unavailable in this mod");
                return NotAvail;
            }

            return GiveLamThrower(viewer,duration);

        // dmg_double and dmg_half require changes inside the player class
        case "dmg_double":
            if (!#defined(vanilla) && !#defined(revision)){
                PlayerMessage("Double Damage effect unavailable in this mod");
                return NotAvail;
            }

            if (isTimerActive('cc_DifficultyTimer')) {
                return TempFail;
            }
            storeFloatValue('cc_damageMult',2.0);

            PlayerMessage(viewer@"made your body extra squishy");
            startNewTimer('cc_DifficultyTimer',duration);
            break;

        case "dmg_half":
            if (!#defined(vanilla) && !#defined(revision)){
                PlayerMessage("Half Damage effect unavailable in this mod");
                return NotAvail;
            }

            if (isTimerActive('cc_DifficultyTimer')) {
                return TempFail;
            }
            storeFloatValue('cc_damageMult',0.5);
            PlayerMessage(viewer@"made your body extra tough!");
            startNewTimer('cc_DifficultyTimer',duration);
            break;

        case "flipped":
            if (!#defined(vanilla) && !#defined(revision)){
                //Changes in player class
                PlayerMessage("Flipped effect unavailable in this mod");
                return NotAvail;
            }

            if (!InGame()) {
                return TempFail;
            }
            if (isTimerActive('cc_RollTimer')) {
                return TempFail;
            }
            if (isTimerActive('cc_ResidentEvil')) {
                return TempFail;
            }
            datastorage.SetConfig('cc_cameraRoll',32768, 3600*12);

            PlayerMessage(viewer@"turned your life upside down");
            startNewTimer('cc_RollTimer',duration);

            return Success;

        case "limp_neck":
            if (!#defined(vanilla) && !#defined(revision)){
                //Changes in player class
                PlayerMessage("Limp Neck effect unavailable in this mod");
                return NotAvail;
            }
            if (!InGame()) {
                return TempFail;
            }
            if (isTimerActive('cc_RollTimer')) {
                return TempFail;
            }
            if (isTimerActive('cc_ResidentEvil')) {
                return TempFail;
            }
            datastorage.SetConfig('cc_cameraRoll',16383, 3600*12);

            PlayerMessage(viewer@"made your head flop to the side");
            startNewTimer('cc_RollTimer',duration);

            return Success;

        case "barrel_roll":
            if (!#defined(vanilla) && !#defined(revision)){
                //Changes in player class
                PlayerMessage("Barrel Roll effect unavailable in this mod");
                return NotAvail;
            }
            if (!InGame()) {
                return TempFail;
            }
            if (isTimerActive('cc_RollTimer')) {
                return TempFail;
            }
            if (isTimerActive('cc_ResidentEvil')) {
                return TempFail;
            }
            datastorage.SetConfig('cc_cameraSpin',1, 3600*12);

            PlayerMessage(viewer@"told you to do a barrel roll");
            startNewTimer('cc_RollTimer',duration);

            return Success;

        case "flashbang":
            if (!InGame()) {
                return TempFail;
            }
            player().ClientFlash(1,vect(50000,50000,50000));
            flashbangSoundId = player().PlaySound(sound'AlarmUnitHum',SLOT_Interface, 100,False,,25);
            flashbangDuration = 3;

            PlayerMessage(viewer@"set off a flashbang!");

            return Success;

        case "eat_beans":
            if (InMenu()) {
                return TempFail;
            }
            if (isTimerActive('cc_EatBeans')) {
                return TempFail;
            }

            PlayerMessage(viewer@"fed you a whole bunch of beans!");

            startNewTimer('cc_EatBeans',duration);

            return Success;

        case "fire_weapon":
            if (player().InHand == None) {
                return TempFail;
            }
            if (player().weapon == None) {
                return TempFail;
            }
            if (!InGame()) {
                return TempFail;
            }
            if (player().RestrictInput()) {
                return TempFail;
            }
            if (!player().weapon.IsInState('Idle')){
                return TempFail;
            }
            player().Fire();
            PlayerMessage(viewer@"made you fire your weapon!");
            break;

        case "next_item":
            if (!InGame()) {
                return TempFail;
            }
            if (player().RestrictInput()) {
                return TempFail;
            }
            player().NextBeltItem();
            PlayerMessage(viewer@"made you change your item!");
            break;

        case "next_hud_color":
            if (player().ThemeManager==None){
                return TempFail;
            }

            return NextHUDColorTheme(viewer);
            break;

        case "quick_load":
            if (!InGame()) {
                return TempFail;
            }
            if (player().RestrictInput()) {
                return TempFail;
            }
            if (quickLoadTriggered){
                return TempFail;
            }
            PlayerMessage(viewer@"is about to do a Quick Load!");

            quickLoadTriggered = True;
            break;

        case "quick_save":
            if (!InGame()) {
                return TempFail;
            }
            if (player().RestrictInput()) {
                return TempFail;
            }
            if (player().dataLinkPlay!=None) {
                return TempFail;
            }
            if (quickLoadTriggered) {
                return TempFail;
            }
            if (trainingTriggered) {
                return TempFail;
            }
            PlayerMessage(viewer@"is about to Quick Save!");
            player().QuickSave();
            break;

        case "nasty_rat":
            if (!InGame()) {
                return TempFail;
            }
            return SpawnNastyRat(viewer);
            break;

        case "drop_piano":
            if (!InGame()) {
                return TempFail;
            }
            return DropPiano(viewer);
            break;

        case "toggle_flashlight":
            if (!InGame()) {
                return TempFail;
            }
            if (!ToggleFlashlight(viewer)){
                return TempFail;
            }
            break;

        case "heal_all_enemies":
            if (!InGame()) {
                return TempFail;
            }
            if (!HealAllEnemies(viewer)){
                return TempFail;
            }
            break;
        case "resident_evil":
            if (!#defined(vanilla) && !#defined(revision)){
                //Changes in player class
                PlayerMessage("Resident Evil effect unavailable in this mod");
                return NotAvail;
            }
            if (!InGame()) {
                return TempFail;
            }
            if (isTimerActive('cc_RollTimer')) {
                return TempFail;
            }
            if (isTimerActive('cc_behindTimer')) {
                return TempFail;
            }
            if (isTimerActive('cc_DoomMode')) {
                return TempFail;
            }
            if (isTimerActive('cc_ResidentEvil')) {
                return TempFail;
            }

            PlayerMessage(viewer@"made your view a little bit more horrific");
            startNewTimer('cc_ResidentEvil',duration);
            dxrCameras.EnableTempFixedCamera();
            return Success;

        case "radioactive":
            if (!InGame()) {
                return TempFail;
            }
            if (isTimerActive('cc_Radioactive')) {
                return TempFail;
            }

            PlayerMessage(viewer@"made you radioactive!");

            startNewTimer('cc_Radioactive',duration);
            break;
        case "corpse_explosion":
            if (!InGame()) {
                return TempFail;
            }
            if (!CorpseExplosion(viewer)){
                return TempFail;
            }
            break;
        case "doom_mode":
            if (!#defined(vanilla)){
                //Changes in player class
                PlayerMessage("Doom Mode effect unavailable in this mod");
                return NotAvail;
            }
            if (!InGame()) {
                return TempFail;
            }
            if (isTimerActive('cc_DoomMode')) {
                return TempFail;
            }
            if (isTimerActive('cc_ResidentEvil')) {
                return TempFail;
            }
            if (isTimerActive('cc_behindTimer')) {
                return TempFail;
            }
            PlayerMessage(viewer@"dragged you to hell!");

            startNewTimer('cc_DoomMode',duration);
            break;
        case "raise_dead":
            if (!InGame()) {
                return TempFail;
            }
            if (!RaiseDead(viewer)){
                return TempFail;
            }
            break;

        case "drop_marbles":
            if (InMenu()) {
                return TempFail;
            }
            if (!DropMarbles(viewer)){
                return TempFail;
            }
            break;

        case "spam_datacubes":
            if (!InGame()){
                return TempFail;
            }
            if (!SpamDatacubes(viewer)){
                return TempFail;
            }
            break;
        case "wine_bullets":
            if (!#defined(vanilla) && !#defined(revision)){
                PlayerMessage("Wine Bullets effect unavailable in this mod");
                return NotAvail;
            }
            if (!InGame()){
                return TempFail;
            }
            if (isTimerActive('cc_WineBullets')) {
                return TempFail;
            }
            datastorage.SetConfig('cc_WineBullets',1, 3600*12);
            PlayerMessage(viewer@"coated all the enemies bullets in wine!");
            startNewTimer('cc_WineBullets',duration);
            break;

        case "blood_god":
            if (Level.Game.bLowGore || Level.Game.bVeryLowGore){
                return TempFail;
            }
            if (!InGame()){
                return TempFail;
            }
            if (isTimerActive('cc_BloodGod')) {
                return TempFail;
            }
            if (!BloodForTheBloodGod()){
                return TempFail;
            }

            startNewTimer('cc_BloodGod',duration);

            PlayerMessage(viewer@"bestowed an offering to the Blood God!");

            break;

        case "random_clothes":
            if (#defined(vmd)){
                return NotAvail;
            }

            //Allow this to be used during conversations, just not while in menus
            if (InMenu()) {
                return TempFail;
            }

           if (!RandomClothes()){
                return TempFail;
           }
            PlayerMessage(viewer@"gave you a fresh new outfit!");

            return Success;

        case "shuffle_belt":
            if (!InGame()){
                return TempFail;
            }

            return ShuffleBelt(viewer);

        case "back_to_academy":
            if (!InGame()){
                return TempFail;
            }
            if (player().RestrictInput()) {
                return TempFail;
            }
            if (trainingTriggered){
                return TempFail;
            }
            if (IsTrainingLevel()){
                return TempFail;
            }
            PlayerMessage(viewer@"thinks you need to go back to the academy!");

            trainingTriggered = True;
            break;

        default:
            return doCrowdControlEventWithPrefix(code, param, viewer, type, duration);
    }

    return Success;
}
//#endregion

//#region Prefix Events
function int doCrowdControlEventWithPrefix(string code, string param[5], string viewer, int type, int duration) {
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
        case "spawnfriendly":
            return SpawnPawnNearPlayer(player(),getScriptedPawnClass(words[1]),True,viewer);
        case "spawnenemy":
            return SpawnPawnNearPlayer(player(),getScriptedPawnClass(words[1]),False,viewer);
        case "giveenemyweapon":
            return GiveAllEnemiesWeapon(getWeaponClass(words[1]),viewer);
        default:
            err("Unknown effect: "$code);
            return NotAvail;
    }

    return Success;
}
//#endregion

defaultproperties
{
    NormalGravity=(X=0,Y=0,Z=-950)
    FloatGrav=(X=0,Y=0,Z=0.15)
    MoonGrav=(X=0,Y=0,Z=-300)
    shouldSave=" (You should save now.)"
}
