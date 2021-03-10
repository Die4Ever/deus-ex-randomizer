class MissionIntro injects MissionIntro;

var bool started_conv;
var bool ran_first_frame;

function FirstFrame()
{
    ran_first_frame = true;
    started_conv = false;
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
    if ( flags.GetInt('Rando_newgameplus_loops') <= 0 || !flags.GetBool('Intro_Played') ) {
        Super.Timer();
        return;
    }

    if (flags.GetBool('Intro_Played'))
    {
        if (DeusExRootWindow(player.rootWindow) != None)
            DeusExRootWindow(player.rootWindow).ClearWindowStack();
        
        player.bStartNewGameAfterIntro = False;
        player.flagBase.SetBool('PlayerTraveling', True, True, 0);
        player.DeleteSaveGameFiles();
        player.bStartingNewGame = True;
        Level.Game.SendPlayer(player, "01_NYC_UNATCOIsland");
    }
}
