class DXRHUDMedBotAddAugsScreen injects HUDMedBotAddAugsScreen;

var PersonaActionButtonWindow btnRemove;

function CreateMedbotLabel() {}

function CreateButtons()
{
    local PersonaButtonBarWindow winActionButtons;

    winActionButtons = PersonaButtonBarWindow(winClient.NewChild(Class'PersonaButtonBarWindow'));
    winActionButtons.SetPos(346, 371);
    winActionButtons.SetWidth(150);

    btnRemove = PersonaActionButtonWindow(winActionButtons.NewChild(Class'DXRPersonaActionButtonWindow'));
    btnRemove.SetButtonText("|&Remove");

    btnInstall = PersonaActionButtonWindow(winActionButtons.NewChild(Class'DXRPersonaActionButtonWindow'));
    btnInstall.SetButtonText(InstallButtonLabel);
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

        case btnInstall:
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

    if (class'#var(injectsprefix)HUDMedBotHealthScreen'.static.isAugsOnly(medBot) && #var(injectsprefix)HUDMedBotNavBarWindow(winNavBar) != None) {
        #var(injectsprefix)HUDMedBotNavBarWindow(winNavBar).CreateExitButton();
        MedbotInterfaceText = "AUGBOT INTERFACE";
    } else if(#var(injectsprefix)HUDMedBotNavBarWindow(winNavBar) != None) {
        #var(injectsprefix)HUDMedBotNavBarWindow(winNavBar).CreateAllButtons();
    }
    Super.CreateMedbotLabel();
}

function SelectAugmentation(PersonaItemButton buttonPressed)
{
    local Augmentation aug;
    local String augDesc;

    if (HUDMedBotAugItemButton(buttonPressed)!=None){
        if (HUDMedBotAugItemButton(buttonPressed).bSlotFull){
            aug = HUDMedBotAugItemButton(buttonPressed).GetAugmentation();
        }
    }

    Super.SelectAugmentation(buttonPressed);

    //If the slot is full, mention that, but still show the description and what slot it goes in
    if (selectedAug==None && selectedAugButton==None && aug!=None){
        aug.UpdateInfo(winInfo);
        augDesc = winInfo.winText.GetText();

        winInfo.Clear();

        winInfo.SetTitle(aug.AugmentationName);

        winInfo.SetText(SlotFullText);
        winInfo.AppendText(winInfo.CR());
        winInfo.AppendText(winInfo.CR());
        winInfo.AppendText(Sprintf(aug.OccupiesSlotLabel, aug.AugLocsText[aug.AugmentationLocation]));
        winInfo.AppendText(winInfo.CR());

        winInfo.AddLine();

        winInfo.SetText(winInfo.CR());
        winInfo.AppendText(augDesc);
    }
}
