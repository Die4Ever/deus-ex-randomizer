//=============================================================================
// MenuScreenRandoOptionsRandomizer
//=============================================================================

class MenuScreenRandoOptionsRandomizer expands MenuScreenRandoOptionsBase;

function CreateChoices()
{
    controlsParent = winClient;
    CreateScrollWindow();

    CreateChoice(class'MenuChoice_Telemetry');
    CreateChoice(class'MenuChoice_JoinDiscord');
    CreateChoice(class'MenuChoice_Website');
    CreateChoice(class'MenuChoice_ReleasePage');
    // TODO: button to open Mastodon?

    CreateChoice(class'MenuChoice_ShowNews');

    controlsParent.SetSize(clientWidth, choiceStartY + (choiceCount * choiceVerticalGap));
}


defaultproperties
{
     Title="Randomizer Options"
}
