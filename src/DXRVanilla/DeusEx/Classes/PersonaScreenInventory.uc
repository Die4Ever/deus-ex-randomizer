class PersonaScreenInventory injects PersonaScreenInventory;

const RefuseLabel = "|&Trash";
const AcceptLabel = "|&Not Trash";

var PersonaActionButtonWindow btnRefusal;

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
        winInfo.AppendText("|n|nDuration: " $ CalcChargedPickupDurations(ChargedPickup(anItem)));
    }else if (AugmentationCannister(anItem)!=None){
        UpdateAugCanDescription(AugmentationCannister(anItem));
    }

    if (BioElectricCell(anItem)!=None){
        winInfo.AppendText("|n|nCurrent Energy: " $ int(player.Energy) $ "/" $ int(player.EnergyMax));
    }
}

function UpdateAugCanDescription(AugmentationCannister ac)
{
    local string desc,augName,augLoc, augDesc;
	local Int canIndex;
	local Augmentation aug;

    //The title doesn't need to show the aug names
    winInfo.winTitle.SetText(ac.default.itemName);

    //Add the aug location to the short description and include the info about the augs below that
    desc = winInfo.winText.GetText();

    for(canIndex=0; canIndex<ArrayCount(ac.AddAugs); canIndex++)
    {
        if (ac.AddAugs[canIndex] != '')
        {
            aug = ac.GetAugmentation(canIndex);

            if (aug != None){
                augName = aug.default.AugmentationName;
                augLoc = aug.AugLocsText[aug.AugmentationLocation];
                desc = class'DXRInfo'.static.ReplaceText(desc, augName, augName$" ("$augLoc$")");
                augDesc = augDesc $   "-------------------------------------------|n";
                augDesc = augDesc $    augName$" ("$augLoc$")";
                augDesc = augDesc $ "|n-------------------------------------------|n";
                augDesc = augDesc $    aug.Description$"|n|n";
            }
        }
    }

    desc = desc $ "|n|n|n" $ augDesc;

    winInfo.winText.SetText(desc);
}

function string CalcChargedPickupDurations(ChargedPickup cp)
{
    local string chargeVals;
    local int i, drain;
    local float workingVal, skillVal;
    local bool curLevel;
    local int maxLevel;

    chargeVals = "";
    maxLevel = 0;
    if (cp.SkillNeeded!=None){
        maxLevel = 3;
    }

    for (i=0;i<=maxLevel;i++){
        workingVal = cp.Default.Charge * 100;// multiplied by 100 to fix rounding issues with ints
        drain = 400.0;
        skillVal = 1.0;
        curLevel = False;
        if (cp.SkillNeeded!=None){
            skillVal = Player.SkillSystem.GetSkillFromClass(cp.skillNeeded).LevelValues[i];
            curLevel = Player.SkillSystem.GetSkillLevel(cp.skillNeeded) == i;
        }
        drain *= skillVal;

        workingVal = workingVal / Max(drain, 1); //How many times can it drain at this rate? Max() converts to int
        workingVal = workingVal / 10.0; //drain happens every 0.1 seconds

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

    btnRefusal = PersonaActionButtonWindow(winActionButtons.NewChild(Class'PersonaActionButtonWindow'));
    btnRefusal.SetButtonText(RefuseLabel);

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

    if ((btnRefusal == None) || (btnDrop == None) || (btnEquip == None) || (btnUse == None))
        return;

    btnRefusal.SetButtonText(RefuseLabel);

    if (selectedItem == None) {
        btnDrop.DisableWindow();
        btnRefusal.DisableWindow();
        btnEquip.DisableWindow();
        btnUse.DisableWindow();
    } else {
        btnEquip.EnableWindow();
        btnUse.EnableWindow();
        btnDrop.EnableWindow();
        btnRefusal.EnableWindow();

        inv = Inventory(selectedItem.GetClientObject());

        if (inv != None) {
            switch (class'DXRLoadouts'.static.GetLootAction(inv.class)) {
                case 0:
                    btnRefusal.SetButtonText(RefuseLabel);
                    break;
                case 1:
                    btnRefusal.SetButtonText(AcceptLabel);
                    break;
                case 2:
                    btnRefusal.SetButtonText(RefuseLabel);
                    btnRefusal.DisableWindow();
                    break;
            }

            if (NanoKeyRing(inv) != None) {
                //Not a regular inventory item, so don't treat it like anything is currently selected
                btnDrop.DisableWindow();
                btnRefusal.DisableWindow();
                btnEquip.DisableWindow();
                btnUse.DisableWindow();
            } else {
                //Handle each button individually

                //"Equip" button text
                if ((inv == player.inHand ) || (inv == player.inHandPending)) {
                    btnEquip.SetButtonText(UnequipButtonLabel);
                } else {
                    btnEquip.SetButtonText(EquipButtonLabel);
                }

                //"Equip" button
                if ((ChargedPickup(inv)!=None && ChargedPickup(inv).bIsActive)){
                    btnEquip.DisableWindow();
                }

                //"Use" button
                if (WeaponMod(inv) != None || AugmentationUpgradeCannister(inv) != None || DeusExWeapon(inv) != None ||
                    AugmentationCannister(inv) != None ||
                    (ChargedPickup(inv)!=None && ChargedPickup(inv).bIsActive)) {

                    btnUse.DisableWindow();
                }

                //"Refusal" button
                if (AugmentationCannister(inv) != None ||
                    (ChargedPickup(inv)!=None && ChargedPickup(inv).bIsActive)) {
                    btnRefusal.DisableWindow();
                }

                //"Drop" button
                if ((ChargedPickup(inv)!=None && ChargedPickup(inv).bIsActive)){
                    btnDrop.DisableWindow();
                }
            }
        } else {
            btnDrop.DisableWindow();
            btnRefusal.DisableWindow();
            btnEquip.DisableWindow();
            btnUse.DisableWindow();
        }
    }
}

function bool ButtonActivated(Window buttonPressed)
{
    local bool ret;

    if (buttonPressed == btnRefusal) {
        if(btnRefusal.buttonText == RefuseLabel) {
            SetRefuseItem();
        } else {
            UnsetRefuseItem();
        }
        return true;
    }

    ret = Super.ButtonActivated(buttonPressed);
    if (PersonaAmmoDetailButton(buttonPressed) != None) {
        btnDrop.DisableWindow();
        btnRefusal.DisableWindow();
        btnEquip.DisableWindow();
        btnUse.DisableWindow();
    }
    return ret;
}

function UnsetRefuseItem()
{
    local Inventory item;

    item = Inventory(selectedItem.GetClientObject());
    if (item == None) return;

    class'DXRLoadouts'.static.SetLootAction(item.class, 0);
    btnRefusal.SetButtonText(RefuseLabel);
    player.ClientMessage(item.ItemName $ " set as not trash.");
}

function SetRefuseItem()
{
    local Inventory item;
    local Vector x, y, z;
    local Vector dropVect;

    item = Inventory(selectedItem.GetClientObject());
    if (item == None) return;

    class'DXRLoadouts'.static.SetLootAction(item.class, 1);

    if (Pickup(item) == None) {
        DropSelectedItem();
    } else {
        // we don't want to drop just 1 copy, so do our own drop code
        GetAxes(player.Rotation, x, y, z);
        dropVect = player.Location + (player.CollisionRadius + 2.0 * item.CollisionRadius) * x;
        dropVect.z += player.BaseEyeHeight; // TODO: change drop height based on where the player is looking

        if(!player.FastTrace(dropVect)) dropVect = player.Location;

        item.DropFrom(dropVect);
        item.bFixedRotationDir = true;
        item.RotationRate.Pitch = (32768 - Rand(65536)) * 4.0;
        item.RotationRate.Yaw = (32768 - Rand(65536)) * 4.0;
    }

    player.ClientMessage(item.ItemName $ " set as trash.");
}
