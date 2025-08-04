class SoundLooper extends info;

var() Sound mySound;
var() float playTime;
var() float delayTime;
var() bool randomizeDelay;
var bool playing;
var int soundHandle;

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

simulated function Tick(float deltaTime)
{
    Super.Tick(deltaTime);
    LastRenderTime = Level.TimeSeconds; //Keep this sucker alive and active
}

function PostPostBeginPlay()
{
    local float f;
    Super.PostPostBeginPlay();
    f = SoundRadius;
    f = (f+1) * 25;
    SetCollisionSize(f, f);
    StartLoopedSound();
}

function Touch(Actor Other)
{
    if (PlayerPawn(Other) != None)
    {
        Super.Touch(Other);
        //DeusExPlayer(Other).ClientMessage("touched " $ self @ soundHandle);
        if (playing && soundHandle==-1){
            PlayLoopedSound();
        }
    }
}

function Untouch(Actor Other)
{
    if (PlayerPawn(Other) != None)
    {
        Super.Untouch(Other);
        //DeusExPlayer(Other).ClientMessage("untouched " $ self @ soundHandle);
        if (playing && soundHandle!=-1){
            DoDelay();
        }
    }
}

function StartLoopedSound()
{
    if (mySound==None) return;

    PlayLoopedSound();
}

function float GetPlayTime()
{
    local float finalPlayTime;

    finalPlayTime = playTime;
    if (finalPlayTime==0){
        finalPlayTime = GetSoundDuration(mySound);
    }

    return finalPlayTime;
}

function float GetDelayTime()
{
    local float finalDelay;

    finalDelay = delayTime;

    //Do delay rando
    if (randomizeDelay && finalDelay>0){
        finalDelay = RandRange(delayTime*0.5,delayTime*1.5);
    }

    return finalDelay;
}

function PlayLoopedSound()
{
    if (soundHandle!=-1){
        StopSound (soundHandle);
        SetTimer(0.0,false);
    }

    soundHandle = PlaySound(mySound, SLOT_Misc, float(SoundVolume)/64.0,, CollisionRadius+64, float(SoundPitch)/64.0);
    SetTimer(GetPlayTime(),true);
    playing=true;
}

function DoDelay()
{
    playing=false;
    if (soundHandle!=-1){
        StopSound (soundHandle);
        SetTimer(0.0,false);
    }
    soundHandle=-1;
    SetTimer(GetDelayTime(),true);
}

function Timer()
{
    if (mySound!=None){
        if (playing){
            //Just finished playing, now delay
            DoDelay();
        } else {
            //Just finished delay, start playing
            PlayLoopedSound();
        }
    }
}

defaultproperties
{
    bCollideActors=True
    SoundRadius=8
    SoundVolume=128
    playTime=0
    delayTime=1
}
