// The DILF follows the player or Resident Evil camera so that the infolink dialog can
//play through it and sound like a consistent volume.
class DataInfoLinkFollower extends Info transient;

var int camMode;
var float moveTime;

function PreBeginPlay()
{
    Super.PreBeginPlay();
    MoveMe();
}

function Tick(float deltaTime)
{
    Super.Tick(deltaTime);

    moveTime += deltaTime;
    if (moveTime < 0.25) return;
    moveTime = 0;

    MoveMe();
}

function MoveMe()
{
    local Actor camSpot;
    local int curCamMode;

    curCamMode = class'DXRCameraModes'.static.StaticGetExpectedCameraMode(self);

    if (Base!=None && curCamMode==camMode) return;

    camMode=curCamMode;

    camSpot = class'DXRCameraModes'.static.GetCameraActor(self);
    SetLocation(camSpot.Location);
    SetBase(camSpot);
}

defaultproperties
{
    bAlwaysTick=True
    camMode=-1;
}
