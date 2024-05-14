//=============================================================================
// MenuScreenRandoOptionsGameplay
//=============================================================================

class MenuScreenRandoOptionsGameplay expands MenuScreenRandoOptionsBase;

function CreateChoices()
{
    CreateChoice(class'MenuChoice_ToggleMemes');
    // TODO: simulated crowd control strength

    if(#defined(vanilla)) {
        CreateChoice(class'MenuChoice_LoadLatest');
        CreateChoice(class'MenuChoice_SaveDuringInfolinks');
        CreateChoice(class'MenuChoice_AutosaveCombat');
        CreateChoice(class'MenuChoice_AutoAugs');
        CreateChoice(class'MenuChoice_ShowKeys');
        CreateChoice(class'MenuChoice_ThrowMelee');
        CreateChoice(class'MenuChoice_AutoWeaponMods');
        CreateChoice(class'MenuChoice_AutoLaser');
        CreateChoice(class'MenuChoice_DecoPickupBehaviour');
    }

    CreateChoice(class'MenuChoice_PasswordAutofill');
    CreateChoice(class'MenuChoice_ConfirmNoteDelete');
    CreateChoice(class'MenuChoice_FixGlitches');
    CreateChoice(class'MenuChoice_AutoLamps');
}

defaultproperties
{
     Title="Randomizer Gameplay"
}
