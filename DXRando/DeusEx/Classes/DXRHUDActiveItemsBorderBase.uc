class DXRHUDActiveItemsBorderBase injects HUDActiveItemsBorderBase;

//Just adding timer-specific objects
function AddIcon(Texture newIcon, Object saveObject)
{
	local HUDActiveItemBase activeItem;
	local HUDActiveItemBase iconWindow;

	// First make sure this object isn't already in the window
	iconWindow = HUDActiveItemBase(winIcons.GetTopChild());
	while(iconWindow != None)
	{
		// Abort if this object already exists!!
		if (iconWindow.GetClientObject() == saveObject)
			return;

		iconWindow = HUDActiveItemBase(iconWindow.GetLowerSibling());
	}

	// Hide if there are no icons visible
	if (++iconCount == 1)
		Show();

	if (saveObject.IsA('Augmentation'))
		activeItem = HUDActiveItemBase(winIcons.NewChild(Class'HUDActiveAug'));
    else if (saveObject.IsA('DXRandoCrowdControlTimer'))
		activeItem = HUDActiveItemBase(winIcons.NewChild(Class'HUDActiveItemTimer'));    
	else
		activeItem = HUDActiveItemBase(winIcons.NewChild(Class'HUDActiveItem'));

	activeItem.SetIcon(newIcon);
	activeItem.SetClientObject(saveObject);
	activeItem.SetObject(saveObject);

	AskParentForReconfigure();
}