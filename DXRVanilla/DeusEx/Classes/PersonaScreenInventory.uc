class PersonaScreenInventory injects PersonaScreenInventory;

var PersonaActionButtonWindow btnGarbage;

function SelectInventory(PersonaItemButton buttonPressed)
{
    Super.SelectInventory(buttonPressed);
    UpdateSelectedItem();
}

function DropSelectedItem()
{
    Super.DropSelectedItem();
    UpdateSelectedItem();
}

function UpdateSelectedItem()
{
    local Inventory anItem;
    if (selectedItem == None)
        return;
    anItem = Inventory(selectedItem.GetClientObject());
    UpdateWinInfo(anItem);
}

function UpdateWinInfo(Inventory inv)
{
    local DeusExPickup anItem;
    winInfo.Clear();

    if (inv == None)
        return;

    inv.UpdateInfo(winInfo);
    anItem = DeusExPickup(inv);
    if(anItem != None && anItem.maxCopies > 1) {
        winInfo.AppendText(" / " $ anItem.maxCopies);
    }else if (ChargedPickup(anItem)!=None){
        winInfo.AppendText("|n|nDuration: "$CalcChargedPickupDurations(ChargedPickup(anItem)));
    }

    if (BioElectricCell(anItem)!=None){
        winInfo.AppendText("|n|nCurrent Energy: "$int(player.Energy)$"/"$int(player.EnergyMax));
    }
}


function string CalcChargedPickupDurations(ChargedPickup cp)
{
    local string chargeVals;
    local int i;
    local float workingVal, skillVal, drain;
    local bool curLevel;
    local int maxLevel;

    chargeVals = "";
    maxLevel = 0;
    if (cp.SkillNeeded!=None){
        maxLevel = 3;
    }

    for (i=0;i<=maxLevel;i++){
        workingVal = cp.Default.Charge;
        drain = 4.0;
        skillVal = 1.0;
        curLevel = False;
        if (cp.SkillNeeded!=None){
            skillVal = Player.SkillSystem.GetSkillFromClass(cp.skillNeeded).LevelValues[i];
            curLevel = Player.SkillSystem.GetSkillLevel(cp.skillNeeded) == i;
        }
        drain *=skillVal;
        if (drain < 1) drain=1;

        workingVal = workingVal/drain; //How many times can it drain at this rate?
        workingVal = workingVal/10.0; //drain happens every 0.1 seconds

        if (curLevel){
            chargeVals = chargeVals $ ">";
        }

        chargeVals = chargeVals $ Int(workingVal)$"s";

        if (curLevel){
            chargeVals = chargeVals $ "<";
        }

        if (i!=maxLevel){
            chargeVals = chargeVals $ " / ";
        }
    }

    return chargeVals;
}

//Dragging an item out of the inventory grid will now drop it
function FinishButtonDrag()
{
    local Inventory draggedItem;
    local Bool shouldDrop;

    shouldDrop=False;
    draggedItem=None;

    if (lastDragOverWindow==None){
        draggedItem=Inventory(dragButton.GetClientObject());
        shouldDrop = (draggedItem!=None);
    }

    Super.FinishButtonDrag();

    if (shouldDrop && draggedItem!=None){
        SelectInventoryItem(draggedItem);
        DropSelectedItem();
    }
}

//Try to prevent item stacking
//If an item is being "dragged" while the inventory is closing, put it back where it started
event DescendantRemoved(Window descendant)
{
    local Inventory draggedItem;

    if (descendant==winStatus){ //Only act as the inventory is being dismantled
        if (class'MenuChoice_FixGlitches'.default.enabled && bDragging && dragButton!=None){
            draggedItem=Inventory(dragButton.GetClientObject());
            if (draggedItem!=None){
                //Return the item to the slot it started in
                player.PlaceItemInSlot(draggedItem,draggedItem.invPosX,draggedItem.invPosY);
            }
        }
    }
    Super.DescendantRemoved(descendant);
}

function CreateButtons()
{
	local PersonaButtonBarWindow winActionButtons;

	winActionButtons = PersonaButtonBarWindow(winClient.NewChild(Class'PersonaButtonBarWindow'));
	winActionButtons.SetPos(9, 339);
	winActionButtons.SetWidth(267);

	btnGarbage = PersonaActionButtonWindow(winActionButtons.NewChild(Class'PersonaActionButtonWindow'));
	btnGarbage.SetButtonText("Trash");

	btnDrop = PersonaActionButtonWindow(winActionButtons.NewChild(Class'PersonaActionButtonWindow'));
	btnDrop.SetButtonText(DropButtonLabel);

	btnUse = PersonaActionButtonWindow(winActionButtons.NewChild(Class'PersonaActionButtonWindow'));
	btnUse.SetButtonText(UseButtonLabel);

	btnEquip = PersonaActionButtonWindow(winActionButtons.NewChild(Class'PersonaActionButtonWindow'));
	btnEquip.SetButtonText(EquipButtonLabel);
}

function EnableButtons()
{
	local Inventory inv;

	// Make sure all the buttons exist!
	if ((btnGarbage == None) || (btnDrop == None) || (btnEquip == None) || (btnUse == None))
		return;

	if (selectedItem == None) {
		btnGarbage.DisableWindow();
		btnDrop.DisableWindow();
		btnEquip.DisableWindow();
		btnUse.DisableWindow();
	} else {
		btnGarbage.EnableWindow();
		btnEquip.EnableWindow();
		btnUse.EnableWindow();
		btnGarbage.EnableWindow();
		btnDrop.EnableWindow();

		inv = Inventory(selectedItem.GetClientObject());

		if (inv != None) {
			// Anything can be dropped, except the NanoKeyRing
			btnDrop.EnableWindow();

			if (inv.IsA('WeaponMod')) {
				btnChangeAmmo.DisableWindow();
				btnUse.DisableWindow();
			} else if (inv.IsA('NanoKeyRing')) {
				btnChangeAmmo.DisableWindow();
				btnDrop.DisableWindow();
				btnEquip.DisableWindow();
				btnUse.DisableWindow();
                btnGarbage.EnableWindow();
			}
			// Augmentation Upgrade Cannisters cannot be used
			// on this screen
			else if ( inv.IsA('AugmentationUpgradeCannister') ) {
				btnUse.DisableWindow();
				btnChangeAmmo.DisableWindow();
			}
			// Ammo can't be used or equipped
			else if ( inv.IsA('Ammo') ) {
				btnUse.DisableWindow();
				btnEquip.DisableWindow();
                btnGarbage.DisableWindow();
			} else {
				if ((inv == player.inHand ) || (inv == player.inHandPending))
					btnEquip.SetButtonText(UnequipButtonLabel);
				else
					btnEquip.SetButtonText(EquipButtonLabel);
			}
		}
		else {
			btnChangeAmmo.DisableWindow();
			btnDrop.DisableWindow();
			btnEquip.DisableWindow();
			btnUse.DisableWindow();
		}
	}
}

function bool ButtonActivated(Window buttonPressed)
{
    local bool ret;

    if (buttonPressed == btnGarbage) {
        Garbage();
        return true;
    }

    ret = Super.ButtonActivated(buttonPressed);
    if (PersonaAmmoDetailButton(buttonPressed) != None) {
        btnDrop.DisableWindow();
        btnGarbage.DisableWindow();
        btnEquip.DisableWindow();
        btnUse.DisableWindow();
    }
    return ret;
}

function Garbage()
{
    local DXRando dxr;
    local DataStorage datastorage;
    local Inventory inv;
    local string item_refusals;

    foreach player.AllActors(class'DXRando', dxr) break;
    datastorage = class'DataStorage'.static.GetObj(dxr);
    inv = Inventory(selectedItem.GetClientObject());

    item_refusals = datastorage.GetConfigKey("item_refusals");
    if (InStr(item_refusals, "," $ inv.class.name $ ",") == -1) {
        if (item_refusals == "") item_refusals = ",";
        item_refusals = item_refusals $ inv.class.name $ ",";
        datastorage.SetConfig("item_refusals", item_refusals, 2147483647);
    }

    DropSelectedItem();

    log("item_refusals: " $ item_refusals);
    player.ClientMessage("ButtonActivated new item_refusals: " $ item_refusals);
}
