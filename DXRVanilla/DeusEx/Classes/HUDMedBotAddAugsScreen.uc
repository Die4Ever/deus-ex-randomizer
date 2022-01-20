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
	local int buttonIndex;

	for(buttonIndex=0; buttonIndex<arrayCount(augItems); buttonIndex++)
	{
		if (augItems[buttonIndex] != None)
			augItems[buttonIndex].Destroy();
            augItems[buttonIndex] = None;
	}
}


