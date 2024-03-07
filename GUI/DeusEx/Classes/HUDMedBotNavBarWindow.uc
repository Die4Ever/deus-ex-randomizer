class DXRHUDMedBotNavBarWindow injects #var(prefix)HUDMedBotNavBarWindow;

function CreateButtons() {}

function CreateAllButtons()
{
    Super.CreateButtons();
}

function CreateExitButton()
{
    Super(#var(prefix)PersonaNavBarBaseWindow).CreateButtons(); // don't create "Health" or "Augmentations" buttons
}

function bool ButtonActivated(Window buttonPressed)
{
	local bool bHandled;
    local Window parent;
	local HUDMedBotHealthScreen parentHealthScreen, newHealthScreen;
	local HUDMedBotAddAugsScreen parentAugScreen, newAugScreen;
	local MedicalBot medBot;

	bHandled = True;

    parent = GetParent();
    parentHealthScreen = HUDMedBotHealthScreen(parent);
    parentAugScreen = HUDMedBotAddAugsScreen(parent);

	switch(buttonPressed)
	{
		case btnHealth:
            if (parentHealthScreen != None) {
                parentHealthScreen.SkipAnimation(True);
                medBot = parentHealthScreen.medBot;
            } else if (parentAugScreen != None) {
                parentAugScreen.SkipAnimation(True);
                medBot = parentAugScreen.medBot;
            }

            newHealthScreen = HUDMedBotHealthScreen(root.InvokeUIScreen(Class'HUDMedBotHealthScreen', True));
            newHealthScreen.SetMedicalBot(medBot);

			break;

		case btnAugs:
            if (parentHealthScreen != None) {
                parentHealthScreen.SkipAnimation(True);
                medBot = parentHealthScreen.medBot;
            } else if (parentAugScreen != None) {
                parentAugScreen.SkipAnimation(True);
                medBot = parentAugScreen.medBot;
            }

            newAugScreen = HUDMedBotAddAugsScreen(root.InvokeUIScreen(Class'HUDMedBotAddAugsScreen', True));
            newAugScreen.SetMedicalBot(medBot);

			break;

		default:
			bHandled = False;
			break;
	}

	if (bHandled)
		return bHandled;
	else
		return Super(PersonaNavBarBaseWindow).ButtonActivated(buttonPressed);
}
