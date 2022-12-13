class VMDR156MenuSelectDifficulty extends DXRMenuSelectDifficulty;

function _InvokeNewGameScreen(float difficulty, DXRando dxr)
{
    local DXRMenuScreenNewGame newGame;
#ifdef vmd
    local MenuSelectDifficulty VMDNewGame;
    local VMDBufferPlayer VMP;

    dxr.flags.SaveFlags();
    // I think we really just need to run DXRSkills here
    dxr.RandoEnter();
    Player.CombatDifficulty = Difficulty;
    VMDNewGame = MenuSelectDifficulty(root.InvokeMenuScreen(Class'MenuSelectDifficulty'));
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
