class VMDR156MenuSelectDifficulty extends DXRMenuSelectDifficulty;

function _InvokeNewGameScreen(float difficulty, DXRando dxr)
{
    local DXRMenuScreenNewGame newGame;
#ifdef vmd
    local VMDMenuSelectCampaign VMDNewGame;
    local VMDBufferPlayer VMP;

    dxr.flags.SaveFlags();
    // I think we really just need to run DXRSkills here
    dxr.RandoEnter();
    VMDNewGame = VMDMenuSelectCampaign(root.InvokeMenuScreen(Class'VMDMenuSelectCampaign'));

    //MADDERS: Call relevant reset data.
    VMP = VMDBufferPlayer(Player);
    if (VMP != None)
    {
        VMP.VMDResetNewGameVars(1);
    }

    //MADDERS: We only call this from the main menu, NOT in game.
    //By this logic, setting it all on the fly is fine.
    Player.CombatDifficulty = Difficulty;
    if (VMDNewGame != None)
        VMDNewGame.SetDifficulty(difficulty);

    return;
#endif
}

function NewGameSetup(float difficulty)
{
    local DXRMenuSetupRando newGame;

    newGame = DXRMenuSetupRando(root.InvokeMenuScreen(Class'VMDR156MenuSetupRando'));

    if (newGame != None) {
        newGame.SetDifficulty(difficulty);
        newGame.Init(dxr);
    }
}
