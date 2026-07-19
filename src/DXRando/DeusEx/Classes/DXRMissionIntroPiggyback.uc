class DXRMissionIntroPiggyback extends DXRMissionPiggyback;

var bool invStolen;

function Timer()
{
    if (baseScript.flags==None) return;

    if (baseScript.flags.GetBool('Intro_Played'))
    {
        if (!invStolen && baseScript.flags.GetInt('Rando_newgameplus_loops') > 0 && DXRandoGameInfo(Level.Game)!=None){ //Should always be true, but just to be safe
            //Revision takes your inventory away in DeusExPlayer StartNewGame,
            //so steal it and give it to the DXRandoGameInfo for safe keeping
            DXRandoGameInfo(Level.Game).stolenInventory=baseScript.player.Inventory;
            DXRandoGameInfo(Level.Game).stolenAugs=baseScript.player.AugmentationSystem;

            baseScript.player.Inventory=None;
            baseScript.player.AugmentationSystem=None;

            invStolen=True;
        }
    }
}
