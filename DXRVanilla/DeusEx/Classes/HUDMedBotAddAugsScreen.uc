class DXRHUDMedBotAddAugsScreen injects HUDMedBotAddAugsScreen;

var PersonaActionButtonWindow btnRemove;

function CreateButtons()
{
	local PersonaButtonBarWindow winActionButtons;

	winActionButtons = PersonaButtonBarWindow(winClient.NewChild(Class'PersonaButtonBarWindow'));
	winActionButtons.SetPos(346, 371);
	winActionButtons.SetWidth(150); 

	btnRemove = PersonaActionButtonWindow(winActionButtons.NewChild(Class'PersonaActionButtonWindow'));
    btnRemove.bTranslucent = false; //This doesn't look amazing, but it covers up the weird transparency in the menu image
	btnRemove.SetButtonText("|&Remove");

	btnInstall = PersonaActionButtonWindow(winActionButtons.NewChild(Class'PersonaActionButtonWindow'));
    btnInstall.bTranslucent = false; //This doesn't look amazing, but it covers up the weird transparency in the menu image
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
    if (selectedAug == None) {
       return; //Shouldn't happen
    }
    
    if (!selectedAug.bHasIt)
    {
        return; //Also shouldn't happen      
    }
        
    selectedAug.Deactivate();
    selectedAug.bHasIt = False;
    
    // Manage our AugLocs[] array
    player.AugmentationSystem.AugLocs[selectedAug.AugmentationLocation].augCount--;
    
    //Icon lookup is BY HOTKEY, so make sure to remove the icon before the hotkey
    player.RemoveAugmentationDisplay(selectedAug);
    
    // Assign hot key back to default
    selectedAug.HotKeyNum = selectedAug.Default.HotKeyNum;
    
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
    
    return;
}
