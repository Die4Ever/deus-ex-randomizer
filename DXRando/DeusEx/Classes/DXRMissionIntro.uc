class DXRMissionIntro injects #var(prefix)MissionIntro;

#ifdef injections
var bool started_conv;
var bool ran_first_frame;
#endif

function Timer()
{
    local int starting_map;

#ifdef injections
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
#endif

    Super(#var(prefix)MissionScript).Timer();

    // After the Intro conversation is over, tell the player to go on
    // to the next map (which will either be the main menu map or
    // the first game mission if we're starting a new game.

    if (flags.GetBool('Intro_Played'))
    {
        flags.SetBool('Intro_Played', False,, 1);
        starting_map = flags.GetInt('Rando_starting_map');
        if(starting_map != 0) {
            player.strStartMap = class'DXRStartMap'.static.GetStartMap(self, starting_map);
            log(self $ " custom starting map " $ starting_map @ player.strStartMap);
#ifdef vmd
            if(VMDBufferPlayer(player) != None)
                VMDBufferPlayer(player).CampaignNewGameMap = player.strStartMap;
#endif
        }
        if( flags.GetInt('Rando_newgameplus_loops') > 0 ) {
            player.bStartNewGameAfterIntro = true;
        }
        player.PostIntro();
    }
}


#ifdef injections
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

function PreTravel()
{
    if( player != None )
        Super.PreTravel();
}
#endif
