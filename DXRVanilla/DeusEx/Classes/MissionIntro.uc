class MissionIntro injects MissionIntro;

var bool started_conv;
var bool ran_first_frame;

function PostPostBeginPlay()
{
    savedSoundVolume = SoundVolume;
    Super.PostPostBeginPlay();
}

function InitStateMachine()
{
    Super.InitStateMachine();
    dxr.flags.Timer();
}

function FirstFrame()
{
    ran_first_frame = true;
    started_conv = false;

    if( flags.GetBool('Intro_Played') ) {
        log("ERROR: "$self$": Intro_Played already set before FirstFrame?");
        flags.SetBool('Intro_Played', false,, -999);
    }
}


function Timer()
{
    if( ran_first_frame == false ) {
        Level.Game.SetGameSpeed(0.05);
        SetTimer(0.075, True);
    }
    if( ran_first_frame == true && started_conv == false ) {
        Super.FirstFrame();
        started_conv = true;
        Level.Game.SetGameSpeed(1);
        SetTimer(checkTime, True);
    }
    Super.Timer();
}

function PreTravel()
{
    if( player != None )
        Super.PreTravel();
}
