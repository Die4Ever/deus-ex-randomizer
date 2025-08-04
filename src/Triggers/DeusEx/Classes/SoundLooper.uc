class SoundLooper extends info;

var int soundHandle;
var Sound mySound;

//Create a SoundLooper, using the sound from the nearest AmbientSound in the checkRad
static function SoundLooper ReplaceAmbientSound(Actor a, vector loc, float checkRad)
{
    local SoundLooper sl;
    local AmbientSound as,closestAS;

    sl = a.Spawn(class'SoundLooper',,,loc);

    foreach a.RadiusActors(class'AmbientSound',as,checkRad,loc){
        if (closestAS==None){
            closestAS = as;
        } else {
            if (VSize(sl.Location - as.Location)<VSize(sl.Location - closestAS.Location)){
                closestAS = as;
            }
        }
    }

    sl.mySound = None;
    if (closestAS!=None){
        sl.AmbientSound = closestAS.AmbientSound;
        sl.SoundPitch = closestAS.SoundPitch;
        sl.SoundRadius = closestAS.SoundRadius;
        sl.SoundVolume = closestAS.SoundVolume;

        closestAS.AmbientSound = None;
    }
}

function PostPostBeginPlay()
{
    local float f;
    Super.PostPostBeginPlay();
    f = SoundRadius;
    f = (f+1) * 25;
    SetCollisionSize(f, f);
    SetTimer(TimerRate, True);
}

function Touch(Actor Other)
{
    if (PlayerPawn(Other) != None)
    {
        Super.Touch(Other);
        //DeusExPlayer(Other).ClientMessage("touched " $ self @ soundHandle);
        SetTimer(TimerRate, True);
        Timer();
    }
}

function Timer()
{
    if (soundHandle!=-1){
        StopSound(soundHandle);
    }

    if (mySound!=None){
        soundHandle = PlaySound(mySound, SLOT_Misc, float(SoundVolume)/64.0,, CollisionRadius+64, float(SoundPitch)/64.0);
    } else {
        soundHandle = -1;
    }
}

defaultproperties
{
    bCollideActors=True
    SoundRadius=8
    SoundVolume=128
    TimerRate=3
    mySound=sound'T7GPianoBad'
    soundHandle=-1
}
