#ifndef revision
class DXRRevMissionIntro extends Actor;
#else
class DXRRevMissionIntro extends RevisionMissionIntro;

function Timer()
{
	if (flags.GetBool('Intro_Played'))
	{
        if (flags.GetInt('Rando_newgameplus_loops') > 0 && DXRandoGameInfo(Level.Game)!=None){ //Should always be true, but just to be safe
            //Revision takes your inventory away in DeusExPlayer StartNewGame,
            //so steal it and give it to the DXRandoGameInfo for safe keeping
            DXRandoGameInfo(Level.Game).stolenInventory=player.Inventory;
            DXRandoGameInfo(Level.Game).stolenAugs=player.AugmentationSystem;

            player.Inventory=None;
            player.AugmentationSystem=None;
        }
    }
    Super.Timer();
}

#endif
