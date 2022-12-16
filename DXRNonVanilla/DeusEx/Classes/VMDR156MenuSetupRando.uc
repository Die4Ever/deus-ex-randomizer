class VMDR156MenuSetupRando extends DXRMenuSetupRando;

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
