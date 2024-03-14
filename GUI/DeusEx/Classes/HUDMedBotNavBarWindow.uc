class DXRHUDMedBotNavBarWindow injects HUDMedBotNavBarWindow;

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
	local HUDMedBotHealthScreen healthScreen;
	local HUDMedBotAddAugsScreen augScreen;
	local MedicalBot medBot;

	bHandled = True;

	switch(buttonPressed)
	{
		case btnHealth:
            augScreen = HUDMedBotAddAugsScreen(GetParent());

            if (augScreen != None) {
                medBot = augScreen.medBot;
                augScreen.SkipAnimation(True);
                healthScreen = HUDMedBotHealthScreen(root.InvokeUIScreen(Class'HUDMedBotHealthScreen', True));
                healthScreen.SetMedicalBot(medBot);
            }

			break;

		case btnAugs:
            healthScreen = HUDMedBotHealthScreen(GetParent());

            if (healthScreen != None) {
                medBot = healthScreen.medBot;
                healthScreen.SkipAnimation(True);
                augScreen = HUDMedBotAddAugsScreen(root.InvokeUIScreen(Class'HUDMedBotAddAugsScreen', True));
                augScreen.SetMedicalBot(medBot);
            }

			break;

		default:
			bHandled = False;
			break;
	}

	if (bHandled)
		return bHandled;
	else
		return Super(#var(prefix)PersonaNavBarBaseWindow).ButtonActivated(buttonPressed);
}
