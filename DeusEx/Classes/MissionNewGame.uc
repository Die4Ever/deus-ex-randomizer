class MissionNewGame extends MissionScript;

function RandoSkills()
{
    log("DXRando MissionNewGame RandoSkills with seed " $ seed);
    Super.RandoSkills();
}

/*function SaveFlags(DeusExPlayer newplayer)
{
    player = newplayer;
    flags = Player.FlagBase;
    SaveSeed(seed);
}*/
