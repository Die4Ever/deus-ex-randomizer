class VMDR156MenuSelectDifficulty extends DXRMenuSelectDifficulty;

#ifdef vmd
function _InvokeNewGameScreen(float difficulty)
{
    local DXRMenuScreenNewGame newGame;
    local MenuSelectDifficulty VMDNewGame;
    local VMDBufferPlayer VMP;
    local DXRando dxr;

    dxr = GetDxr();
    dxr.flags.SaveFlags();
    // I think we really just need to run DXRSkills here
    dxr.RandoEnter();
    Player.CombatDifficulty = Difficulty;
    VMDNewGame = MenuSelectDifficulty(root.InvokeMenuScreen(Class'MenuSelectDifficulty'));
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
#endif
