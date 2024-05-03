//=============================================================================
// MenuScreenRandoOptionsVisuals
//=============================================================================

class MenuScreenRandoOptionsVisuals expands MenuScreenRandoOptionsBase;

function CreateChoices()
{
    CreateChoice(class'MenuChoice_BrightnessBoost');

    if(#defined(vanilla)) {
        CreateChoice(class'MenuChoice_EnergyDisplay');
        CreateChoice(class'MenuChoice_ShowKeys');
        CreateChoice(class'MenuChoice_Epilepsy');
        CreateChoice(class'MenuChoice_BarrelTextures');
    }

    CreateChoice(class'MenuChoice_ShowTeleporters');
}

defaultproperties
{
     Title="Randomizer Visuals"
}
