class SoundLooper extends info;

var int soundHandle;
var Sound mySound;

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
    StopSound(soundHandle);
    soundHandle = PlaySound(mySound, SLOT_Misc, float(SoundVolume)/64.0,, CollisionRadius+64, float(SoundPitch)/64.0);
}

defaultproperties
{
    bCollideActors=True
    SoundRadius=8
    SoundVolume=128
    TimerRate=3
    mySound=sound'T7GPianoBad'
}
