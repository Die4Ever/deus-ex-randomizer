class PersonaScreenInventory injects PersonaScreenInventory;

const RefuseLabel = "|&Trash";
const AcceptLabel = "Not |&Trash";

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
            if (class'DXRLoadouts'.static.IsRefused(inv.class)) {
                btnRefusal.SetButtonText(AcceptLabel);
            } else {
                btnRefusal.SetButtonText(RefuseLabel);
            }

            if (NanoKeyRing(inv) != None) {
                btnDrop.DisableWindow();
                btnRefusal.DisableWindow();
                btnEquip.DisableWindow();
                btnUse.DisableWindow();
            } else {
                if (WeaponMod(inv) != None || AugmentationUpgradeCannister(inv) != None) {
                    btnUse.DisableWindow();
                } else {
                    if ((inv == player.inHand ) || (inv == player.inHandPending))
                        btnEquip.SetButtonText(UnequipButtonLabel);
                    else
                        btnEquip.SetButtonText(EquipButtonLabel);
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
    if(item == None) return;

    class'DXRLoadouts'.static.UnsetRefuseItem(item.class);
    btnRefusal.SetButtonText(RefuseLabel);
    player.ClientMessage(item.ItemName $ " set as not trash.");
}

function SetRefuseItem()
{
    local Inventory item;
    local Pickup droppedItem;
    local Vector x, y, z;
    local Vector dropVect;

    item = Inventory(selectedItem.GetClientObject());
    if(item == None) return;

    class'DXRLoadouts'.static.SetRefuseItem(item.class);

    if (Pickup(item) == None) {
        DropSelectedItem();
    } else {
        droppedItem = Pickup(player.Spawn(item.class));
        droppedItem.numCopies = Pickup(item).numCopies;
        item.Destroy();

        GetAxes(player.Rotation, x, y, z);
        dropVect = player.Location + (player.CollisionRadius + 2.0 * droppedItem.CollisionRadius) * x;
        dropVect.z += player.BaseEyeHeight; // TODO: change drop height based on where the player is looking

        if (player.FastTrace(dropVect)) {
            droppedItem.DropFrom(dropVect);
            droppedItem.bFixedRotationDir = true;
            droppedItem.RotationRate.Pitch = (32768 - Rand(65536)) * 4.0;
            droppedItem.RotationRate.Yaw = (32768 - Rand(65536)) * 4.0;
        }
    }

    player.ClientMessage(item.ItemName $ " set as trash.");
}
