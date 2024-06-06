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
        CreateChoice(class'MenuChoice_AutoLamps');
        CreateChoice(class'MenuChoice_RefuseUseless');
        CreateChoice(class'MenuChoice_RefuseFoodDrink');
        CreateChoice(class'MenuChoice_RefuseMelee');
        CreateChoice(class'MenuChoice_RefuseMisc');
    }

    CreateChoice(class'MenuChoice_PasswordAutofill');
    CreateChoice(class'MenuChoice_ConfirmNoteDelete');
    CreateChoice(class'MenuChoice_FixGlitches');
}

defaultproperties
{
     Title="Randomizer Gameplay"
}
