class DXRCameraModes expands DXRActorsBase transient;

var int tempCameraMode;
var CCResidentEvilCam reCam;

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

function EnableTempThirdPerson()
{
    tempCameraMode=CM_ThirdPerson;
    SetCameraMode(tempCameraMode);
}

function EnableTempFixedCamera()
{
    tempCameraMode=CM_FixedCamera;
    SetCameraMode(tempCameraMode);
}

function DisableTempCamera()
{
    tempCameraMode=CM_Disabled;
    SetCameraMode(GetExpectedCameraMode());
}

function SetFirstPersonCamera()
{
    if (player().conPlay==None){
        player().bBehindView=False;
        player().bCrosshairVisible=True;
    }
    player().ViewTarget=None;
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
#ifdef vanilla
    player().bBehindView=False;
    player().bCrosshairVisible=False;
    if (reCam==None || reCam.bDeleteMe){
        SpawnRECam();
    }
#else
    err("Fixed camera only supported in vanilla!");
#endif
}

function SpawnRECam()
{
    reCam=Spawn(class'CCResidentEvilCam',,,player().Location);
    reCam.BindPlayer(player());
}

function SetCameraMode(int mode)
{
    local name stateName;

    if (player()!=None){
        stateName = player().GetStateName();

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
