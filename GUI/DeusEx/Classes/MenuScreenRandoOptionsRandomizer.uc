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
}


defaultproperties
{
     Title="Randomizer Options"
}
