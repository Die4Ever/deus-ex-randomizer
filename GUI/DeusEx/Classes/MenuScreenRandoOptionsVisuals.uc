//=============================================================================
// MenuScreenRandoOptionsVisuals
//=============================================================================

class MenuScreenRandoOptionsVisuals expands MenuScreenRandoOptionsBase;

function CreateChoices()
{
    CreateChoice(class'MenuChoice_BrightnessBoost');
    CreateChoice(class'MenuChoice_Fog');

    if(#defined(vanilla)) {
        CreateChoice(class'MenuChoice_EnergyDisplay');
        CreateChoice(class'MenuChoice_ShowKeys');
        CreateChoice(class'MenuChoice_Epilepsy');
        CreateChoice(class'MenuChoice_BarrelTextures');
        CreateChoice(class'MenuUIChoiceVisionTint');
    }
    if (#defined(vanilla||revision)){
        CreateChoice(class'MenuChoice_GoalTextures');
    }
    CreateChoice(class'MenuChoice_ShowTeleporters');
    if (#defined(vanilla)) {
        CreateChoice(class'MenuChoice_AutoLamps');
    }
}

defaultproperties
{
     Title="Randomizer Visuals"
}
