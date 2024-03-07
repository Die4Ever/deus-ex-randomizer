#ifdef injections
class DXRHUDMedBotAddAugsScreen injects HUDMedBotAddAugsScreen;
#elseif hx
class DXRHUDMedBotAddAugsScreen extends HXPersonaScreenAugmentationsMedBot;
#else
class DXRHUDMedBotAddAugsScreen extends HUDMedBotAddAugsScreen;
#endif

var PersonaActionButtonWindow btnRemove;

function CreateButtons()
{
    local PersonaButtonBarWindow winActionButtons;

    winActionButtons = PersonaButtonBarWindow(winClient.NewChild(Class'PersonaButtonBarWindow'));
    winActionButtons.SetPos(346, 371);
    winActionButtons.SetWidth(150);

    btnRemove = PersonaActionButtonWindow(winActionButtons.NewChild(Class'DXRPersonaActionButtonWindow'));
    btnRemove.SetButtonText("|&Remove");

#ifdef hx
    InstallButton = PersonaActionButtonWindow(winActionButtons.NewChild(Class'DXRPersonaActionButtonWindow'));
    InstallButton.SetButtonText(InstallButtonLabel);
#else
    btnInstall = PersonaActionButtonWindow(winActionButtons.NewChild(Class'DXRPersonaActionButtonWindow'));
    btnInstall.SetButtonText(InstallButtonLabel);
#endif
}

function EnableButtons()
{
    Super.EnableButtons();

    if (PersonaAugmentationItemButton(selectedAugButton) != None && (selectedAug.AugmentationLocation != LOC_Default))
    {
        btnRemove.EnableWindow(True);
    } else {
         btnRemove.EnableWindow(False);
    }
}

function bool ButtonActivated(Window buttonPressed)
{
    local bool bHandled;

    bHandled   = True;

    switch(buttonPressed)
    {
        case btnRemove:
            RemoveAugmentation();
            break;

#ifdef hx
        case InstallButton:
#else
        case btnInstall:
#endif
            InstallAugmentation();
            break;
        default:
            bHandled = False;
            break;
    }

    if (bHandled)
        return true;
    else
        return Super.ButtonActivated(buttonPressed);

    return bHandled;
}

function RemoveAugmentation()
{
    class'DXRAugmentations'.static.RemoveAug(player,selectedAug);

    //Deselect the aug
    selectedAug = None;
    selectedAugButton = None;

    // play a cool animation
    medBot.PlayAnim('Scan');

    // Update the Installed Augmentation Icons
    DestroyAugmentationButtons();
    CreateAugmentationButtons();

    //Remove the aug description
    winInfo.Clear();

    // Need to update the aug list
    PopulateAugCanList();

    return;
}

function DestroyAugmentationButtons()
{
    local int buttonIndex,highlightIndex;

    for(buttonIndex=0; buttonIndex<arrayCount(augItems); buttonIndex++)
    {
        if (augItems[buttonIndex] != None)
            augItems[buttonIndex].Destroy();
            augItems[buttonIndex] = None;
    }

    //Remove the beefy bits from the body
    for(highlightIndex=0;highlightIndex<arrayCount(augHighlightWindows);highlightIndex++){
	    augHighlightWindows[highlightIndex].Hide();
    }
}

function SetMedicalBot(MedicalBot newBot, optional bool bPlayAnim)
{
    Super.SetMedicalBot(newBot, bPlayAnim);

    if (medBot != None && medBot.augsOnly) {
        HUDMedBotNavBarWindow(winNavBar).CreateExitButton();
    } else {
        HUDMedBotNavBarWindow(winNavBar).CreateAllButtons();
    }
}
