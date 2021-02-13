class MissionIntro injects MissionIntro;

function Timer()
{
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
