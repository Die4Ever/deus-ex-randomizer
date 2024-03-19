class VMDR175MenuSetupRando extends DXRMenuSetupRando;

#ifdef vmd175
function _InvokeNewGameScreen(float difficulty)
{
    local DXRMenuScreenNewGame newGame;
    local VMDMenuSelectCustomDifficulty VMDNewGame;
    local VMDBufferPlayer VMP;
    local DXRando dxr;

    dxr = GetDxr();
    dxr.flags.SaveFlags();
    // I think we really just need to run DXRSkills here
    dxr.RandoEnter();
    VMDNewGame = VMDMenuSelectCustomDifficulty(root.InvokeMenuScreen(Class'VMDMenuSelectCustomDifficulty'));

    //MADDERS: Call relevant reset data.
    VMP = VMDBufferPlayer(Player);
    if (VMP != None)
    {
        VMP.VMDResetNewGameVars(1);
    }

    Player.CombatDifficulty = difficulty;
}
#endif
