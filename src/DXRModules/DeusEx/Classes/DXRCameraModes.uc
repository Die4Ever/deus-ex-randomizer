class DXRCameraModes expands DXRActorsBase transient;

var int tempCameraMode;
var CCResidentEvilCam reCam;
var bool aimLaserDisabled;

//Enums are really annoying, so just use consts instead
const CM_FirstPerson = 0;
const CM_ThirdPerson = 1;
const CM_FixedCamera = 2;

const CM_Disabled = -1;

function AnyEntry()
{
    Super.AnyEntry();
    SetTimer(0.25, true);
    SetCameraMode(GetExpectedCameraMode());
}

simulated function Timer()
{
    if( dxr == None || dxr.flagbase == None ) {
        return;
    }
    SetCameraMode(GetExpectedCameraMode());
}

///////////////////////////////////////////////////////////////////

static function Actor GetDataInfoLinkFollower(Actor a)
{
    local DataInfoLinkFollower dilf;

    foreach a.AllActors(class'DataInfoLinkFollower',dilf){break;}

    if (dilf==None){
        dilf = a.Spawn(class'DataInfoLinkFollower');
    }

    return dilf;
}

static function Actor GetCameraActor(Actor a)
{
    local DXRCameraModes dxrcm;
    local #var(PlayerPawn) p;
    local bool isPlayer;

    dxrcm = DXRCameraModes(class'DXRCameraModes'.static.Find());

    isPlayer=true;
    if (dxrcm!=None && dxrcm.GetExpectedCameraMode()==CM_FixedCamera){
        isPlayer=false;
    }

    if (isPlayer) {
        if (dxrcm!=None){
            return dxrcm.Player();
        }
        foreach a.AllActors(class'#var(PlayerPawn)',p) break;
        return p;
    } else {
        return dxrcm.reCam;
    }

}

///////////////////////////////////////////////////////////////////

//0 = First Person
//1 = Third Person
//2 = Fixed Camera
function int GetExpectedCameraMode()
{
    if (tempCameraMode>CM_Disabled){
        return tempCameraMode;
    }

    return dxr.flags.moresettings.camera_mode;
}

static function int StaticGetExpectedCameraMode(Actor a)
{
    local DXRCameraModes dxrcm;

    dxrcm = DXRCameraModes(class'DXRCameraModes'.static.Find());

    if (dxrcm==None) return 0;

    return dxrcm.GetExpectedCameraMode();
}

///////////////////////////////////////////////////////////////////

function bool IsFirstPersonGame()
{
    return dxr.flags.moresettings.camera_mode==CM_FirstPerson;
}

function bool IsThirdPersonGame()
{
    return dxr.flags.moresettings.camera_mode==CM_ThirdPerson;
}

function bool IsFixedCamGame()
{
    return dxr.flags.moresettings.camera_mode==CM_FixedCamera;
}

///////////////////////////////////////////////////////////////////

function EnableTempThirdPerson(optional bool disableAimLaser)
{
    tempCameraMode=CM_ThirdPerson;
    if(dxr.flags.moresettings.camera_mode == CM_FirstPerson) {
        aimLaserDisabled = disableAimLaser;
    }
    SetCameraMode(tempCameraMode);
}

function EnableTempFixedCamera(optional bool disableAimLaser)
{
    tempCameraMode=CM_FixedCamera;
    if(dxr.flags.moresettings.camera_mode == CM_FirstPerson) {
        aimLaserDisabled = disableAimLaser;
    }
    SetCameraMode(tempCameraMode);
}

function DisableTempCamera()
{
    tempCameraMode=CM_Disabled;
    aimLaserDisabled=false;
    SetCameraMode(GetExpectedCameraMode());
}

function SetFirstPersonCamera()
{
    if (player().conPlay==None){
        player().bBehindView=False;
        player().bCrosshairVisible=True;
    }
    player().ViewTarget=None;
    player().Style= STY_Normal;
    if (reCam!=None){
        reCam.Destroy();
        reCam=None;
    }
}

function SetThirdPersonCamera()
{
    player().bBehindView=True;
    player().bCrosshairVisible=False;
    player().ViewTarget=None;
    if (reCam!=None){
        reCam.Destroy();
        reCam=None;
    }
    if (player().bIsCrouching || player().bForceDuck){
        player().Style= STY_Translucent;
    } else {
        player().Style= STY_Normal;
    }
}

function SetFixedCamera()
{
    if(#defined(vanilla || revision)){
        player().bBehindView=False;
        player().bCrosshairVisible=False;
        player().Style= STY_Normal;
        if (reCam==None || reCam.bDeleteMe){
            SpawnRECam();
        }
    } else {
        err("Fixed camera not supported in this mod!");
    }
}

function CCResidentEvilCam FindRECam()
{
    local CCResidentEvilCam cam;

    foreach AllActors(class'CCResidentEvilCam',cam){
        if (cam.bDeleteMe) continue;

        return cam;
    }
    return None;
}

function SpawnRECam()
{
    local CCResidentEvilCam cam;

    if (reCam!=None && reCam.bDeleteMe == false) return;

    cam = FindRECam();

    if (cam!=None){
        reCam = cam;
        reCam.BindPlayer(player());
        return;
    }

    reCam=Spawn(class'CCResidentEvilCam',,,player().Location);
    reCam.BindPlayer(player());
}

function SetCameraMode(int mode)
{
    local name stateName;
    local #var(PlayerPawn) p;
    local Window topWin;

    p = player();
    if (p!=None){
        stateName = p.GetStateName();

        #ifdef vmd2
        if(DeusExRootWindow(p.rootWindow) != None) {
            topWin = DeusExRootWindow(p.rootWindow).GetTopWindow();
            if(VMDMenuModifyAppearance(topWin) != None) {
                return;
            }
        }
        #endif

        //These are the possible states when you're in a cutscene
        if (stateName=='Interpolating' || stateName=='Paralyzed'){
            mode = CM_FirstPerson; //Leave it in first person
        } else if (stateName=='Dying') {
            return; // setting camera mode while dying causes your weapon and hand to show after dying
        }
    } else {
        err("SetCameraMode no player");
        return;
    }

    switch(mode){
        case CM_FirstPerson:  //First Person
            SetFirstPersonCamera();
            break;

        case CM_ThirdPerson:  //Third Person
            SetThirdPersonCamera();
            break;

        case CM_FixedCamera:  //Fixed Camera
            SetFixedCamera();
            break;

        default:
            err("Unknown camera mode "$mode);
            break;
    }
}



defaultproperties
{
    tempCameraMode=-1
}
