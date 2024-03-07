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
	local HUDMedBotHealthScreen healthScreen;
	local HUDMedBotAddAugsScreen augsScreen;
	local MedicalBot medBot;

	bHandled = True;

    parent = GetParent();
    healthScreen = HUDMedBotHealthScreen(parent);
    augsScreen = HUDMedBotAddAugsScreen(parent);

	switch(buttonPressed)
	{
		case btnHealth:
            if (augsScreen != None) {
                medBot = augsScreen.medBot;
                augsScreen.SkipAnimation(True);
                healthScreen = HUDMedBotHealthScreen(root.InvokeUIScreen(Class'HUDMedBotHealthScreen', True));
                healthScreen.SetMedicalBot(medBot);
            }
			break;

		case btnAugs:
            if (healthScreen != None) {
                medBot = healthScreen.medBot;
                healthScreen.SkipAnimation(True);
                augsScreen = HUDMedBotAddAugsScreen(root.InvokeUIScreen(Class'HUDMedBotAddAugsScreen', True));
                augsScreen.SetMedicalBot(medBot);
            }
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
