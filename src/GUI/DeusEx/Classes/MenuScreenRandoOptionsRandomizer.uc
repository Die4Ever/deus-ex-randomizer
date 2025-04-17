//=============================================================================
// MenuScreenRandoOptionsRandomizer
//=============================================================================

class MenuScreenRandoOptionsRandomizer expands MenuScreenRandoOptionsBase;

function CreateChoices()
{
    CreateChoice(class'MenuChoice_Telemetry');
    CreateChoice(class'MenuChoice_JoinDiscord');
    CreateChoice(class'MenuChoice_Website');
    CreateChoice(class'MenuChoice_ReleasePage');
    // TODO: button to open Mastodon?

    CreateChoice(class'MenuChoice_ShowNews');
    CreateChoice(class'MenuChoice_ShowBingoUpdates');

    CreateChoice(class'MenuChoice_ToggleMemes');
    CreateChoice(class'MenuChoice_OctoberCosmetics');
    CreateChoice(class'MenuChoice_ShowHints');
    CreateChoice(class'MenuChoice_ShowDeathHints');
    CreateChoice(class'MenuChoice_JCGenderSkin');
}


defaultproperties
{
     Title="Randomizer Options"
}
