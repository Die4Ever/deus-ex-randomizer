class DXRCameraModes expands DXRActorsBase;

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
    SetTimer(0.5, true);
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
}

#ifdef vanilla
function SetFixedCamera()
{
    player().bBehindView=False;
    player().bCrosshairVisible=False;
    if (reCam==None){
        SpawnRECam();
    }
}

function SpawnRECam()
{
    reCam=Spawn(class'CCResidentEvilCam',,,player().Location);
    reCam.BindPlayer(player());
}
#endif

function SetCameraMode(int mode)
{
    local name stateName;

    //player().ClientMessage("tempCameraMode: "$tempCameraMode$"   mode being set: "$mode);

    if (player()!=None){
        stateName = player().GetStateName();

        //These are the possible states when you're in a cutscene
        if (stateName=='Interpolating' || stateName=='Paralyzed'){
            mode = CM_FirstPerson; //Leave it in first person
        }
    }

    switch(mode){
        case CM_FirstPerson:  //First Person
            SetFirstPersonCamera();
            break;

        case CM_ThirdPerson:  //Third Person
            SetThirdPersonCamera();
            break;

        case CM_FixedCamera:  //Fixed Camera
#ifdef vanilla
            SetFixedCamera();
#else
            player().ClientMessage("Fixed camera only supported in vanilla!");
#endif
            break;

        default:
            player().ClientMessage("Unknown camera mode "$mode);
            break;
    }
}



defaultproperties
{
    tempCameraMode=-1
}
