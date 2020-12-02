//=============================================================================
// MenuSelectDifficulty
//=============================================================================

class DXRMenuSelectDifficulty injects MenuSelectDifficulty;

// ----------------------------------------------------------------------
// InvokeNewGameScreen()
// ----------------------------------------------------------------------

function InvokeNewGameScreen(float difficulty)
{
    local DXRMenuSetupRando newGame;

    newGame = DXRMenuSetupRando(root.InvokeMenuScreen(Class'DXRMenuSetupRando'));

    if (newGame != None)
        newGame.SetDifficulty(difficulty);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     ButtonNames(0)="Easy"
     ButtonNames(1)="Medium"
     ButtonNames(2)="Hard"
     ButtonNames(3)="Realistic"
     ButtonNames(4)="Previous Menu"
     buttonXPos=7
     buttonWidth=245
     buttonDefaults(0)=(Y=13,Action=MA_Custom,Key="EASY")
     buttonDefaults(1)=(Y=49,Action=MA_Custom,Key="MEDIUM")
     buttonDefaults(2)=(Y=85,Action=MA_Custom,Key="HARD")
     buttonDefaults(3)=(Y=121,Action=MA_Custom,Key="REALISTIC")
     buttonDefaults(4)=(Y=179,Action=MA_Previous)
     Title="Select Combat Difficulty"
     ClientWidth=258
     ClientHeight=221
     clientTextures(0)=Texture'DeusExUI.UserInterface.MenuDifficultyBackground_1'
     clientTextures(1)=Texture'DeusExUI.UserInterface.MenuDifficultyBackground_2'
     textureRows=1
     textureCols=2
}
