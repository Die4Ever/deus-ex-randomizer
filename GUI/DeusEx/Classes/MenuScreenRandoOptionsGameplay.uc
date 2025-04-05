//=============================================================================
// MenuScreenRandoOptionsGameplay
//=============================================================================

class MenuScreenRandoOptionsGameplay expands MenuScreenRandoOptionsBase;

function CreateChoices()
{
    // TODO: simulated crowd control strength

#ifdef vanilla
    CreateChoice(class'MenuChoice_LoadLatest');
    CreateChoice(class'MenuChoice_SaveDuringInfolinks');
    CreateChoice(class'MenuChoice_AutosaveCombat');
    CreateChoice(class'MenuChoice_AutoAugs');
    CreateChoice(class'MenuChoice_ShowKeys');
    CreateChoice(class'MenuChoice_ThrowMelee');
    CreateChoice(class'MenuChoice_AutoWeaponMods');
    CreateChoice(class'MenuChoice_AutoLaser');
    CreateChoice(class'MenuChoice_DecoPickupBehaviour');
    CreateChoice(class'MenuChoice_LootActionUseless');
    CreateChoice(class'MenuChoice_LootActionFoodSoda');
    CreateChoice(class'MenuChoice_LootActionAlcohol');
    CreateChoice(class'MenuChoice_LootActionMelee');
    CreateChoice(class'MenuChoice_LootActionMisc');
#endif

    CreateChoice(class'MenuChoice_PasswordAutofill');
    CreateChoice(class'MenuChoice_ConfirmNoteDelete');
    CreateChoice(class'MenuChoice_FixGlitches');
    CreateChoice(class'MenuChoice_NewGamePlus');
    CreateChoice(class'MenuChoice_ShowNewSeed');
#ifdef vanilla||revision
    CreateChoice(class'MenuChoice_LockBelt');
#endif

    if(#bool(vanilla)) {
        CreateChoice(class'MenuChoice_BalanceAugs');
        CreateChoice(class'MenuChoice_BalanceSkills');
        CreateChoice(class'MenuChoice_BalanceItems');
        CreateChoice(class'MenuChoice_BalanceMaps');
        CreateChoice(class'MenuChoice_BalanceEtc');
    }
}

defaultproperties
{
     Title="Randomizer Gameplay"
}
