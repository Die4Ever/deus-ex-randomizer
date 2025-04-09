class VMDR156MenuSetupRando extends DXRMenuSetupRando;

#ifdef vmd
function _InvokeNewGameScreen(float difficulty)
{
    local DXRMenuScreenNewGame newGame;
    local VMDMenuSelectCampaign VMDNewGame;
    local VMDBufferPlayer VMP;
    local DXRando dxr;

    dxr = GetDxr();
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
    Player.CombatDifficulty = difficulty;
    if (VMDNewGame != None)
        VMDNewGame.SetDifficulty(difficulty);

    return;
}
#endif
