class MissionNewGame extends MissionScript;

function RandoSkills()
{
    log("MissionNewGame RandoSkills with seed " $ seed);
    Super.RandoSkills();
}

function SaveFlags(DeusExPlayer newplayer, int newseed)
{
    player = newplayer;
    flags = Player.FlagBase;
    SaveSeed(newseed);
}
