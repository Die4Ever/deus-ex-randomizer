//=============================================================================
// MenuScreenRandoOptionsVisuals
//=============================================================================

class MenuScreenRandoOptionsVisuals expands MenuScreenRandoOptionsBase;

function CreateChoices()
{
    controlsParent = winClient;
    CreateScrollWindow();

    CreateChoice(class'MenuChoice_BrightnessBoost');

    if(#defined(vanilla)) {
        CreateChoice(class'MenuChoice_EnergyDisplay');
        CreateChoice(class'MenuChoice_ShowKeys');
        CreateChoice(class'MenuChoice_Epilepsy');
        CreateChoice(class'MenuChoice_BarrelTextures');
    }

    CreateChoice(class'MenuChoice_ShowTeleporters');

    controlsParent.SetSize(clientWidth, choiceStartY + (choiceCount * choiceVerticalGap));
}

defaultproperties
{
     Title="Randomizer Visuals"
     ClientHeight=270
     helpPosY=234//helpPosY = ClientHeight - 36
}
