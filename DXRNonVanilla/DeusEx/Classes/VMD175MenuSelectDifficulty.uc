class VMDR175MenuSelectDifficulty extends DXRMenuSelectDifficulty;

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

function NewGameSetup(float difficulty)
{
    local DXRMenuSetupRando newGame;

    newGame = DXRMenuSetupRando(root.InvokeMenuScreen(Class'VMDR175MenuSetupRando'));

    if (newGame != None) {
        newGame.SetDifficulty(difficulty);
        newGame.Init(dxr);
    }
}
#endif
