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

#ifdef gmdxnotae
    GMDX9UnboostPassiveAugs(selectedAug);
#endif

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

    bTickEnabled = True;
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

function Tick(float deltaTime)
{
    if(medBot == None || medBot.bDeleteMe || player == None || player.bDeleteMe) {
        player = None;
        medBot = None;
        root.ClearWindowStack();
        return;
    }
}





#ifdef gmdxnotae

//Unboost passive augs that have been enhanced by Synthetic Heart automatically
function GMDX9UnboostPassiveAugs(Augmentation selected)
{
    local Augmentation aug;

    if (AugHeartLung(selected)==None) return; //Only do this for Synthetic Heart

    aug = player.AugmentationSystem.FirstAug;
    while (aug!=None){
        if (aug.bHasIt && aug.bAlwaysActive && aug.bBoosted){
            //Unboost
            aug.bBoosted = false;
            aug.CurrentLevel = Max(0,aug.CurrentLevel-1);
        }
        aug = aug.next;
    }
}
function InstallAugmentation()
{
    local Augmentation aug;
    local Augmentation other;

    //Make sure a button is actually selected
    if (HUDMedBotAugItemButton(selectedAugButton) == None) return;

    //Find the aug being installed
    aug = HUDMedBotAugItemButton(selectedAugButton).GetAugmentation();
    if (aug!=None){
        if (aug.IsA('AugHeartLung')){ //Installing Synth Heart
            //Synthetic Heart boosts the augs in the original InstallAugmentation function.
            //make sure all passive augs that we have get marked as boosted
            other = player.AugmentationSystem.FirstAug;
            while (other!=None){
                if (other.bHasIt && other.bAlwaysActive){
                    //Mark the aug as boosted
                    //It will have it's level increased in Super.InstallAugmentation
                    other.bBoosted=true;
                }
                other = other.next;
            }
        } else if (aug.bAlwaysActive && aug.CurrentLevel != aug.MaxLevel) { //Installing a different passive
            //See if we have Synthetic Heart already installed
            other = player.AugmentationSystem.FirstAug;
            while (other!=None){
                if (AugHeartLung(other)!=None && other.bHasIt){
                    //We have Synthetic Heart!  Pre-boost the aug
                    aug.CurrentLevel+=1;
                    aug.bBoosted=true;
                    break;
                }
                other = other.next;
            }
        }
    }

    Super.InstallAugmentation();
}
#endif
