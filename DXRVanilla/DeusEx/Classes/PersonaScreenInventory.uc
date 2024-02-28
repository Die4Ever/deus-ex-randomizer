class PersonaScreenInventory injects PersonaScreenInventory;

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

    if (shouldDrop){
        SelectInventoryItem(draggedItem);
        DropSelectedItem();
    }
}

//Try to prevent item stacking
//If an item is being "dragged" while the inventory is closing, drop it
event DescendantRemoved(Window descendant)
{
    local Inventory draggedItem;
    local bool bFixGlitches;

    if (descendant==winItems){ //Only act as the inventory is being dismantled
        bFixGlitches = bool(player.ConsoleCommand("get #var(package).MenuChoice_FixGlitches enabled"));

        if (bFixGlitches && bDragging && dragButton!=None){
            draggedItem=Inventory(dragButton.GetClientObject());
            if (draggedItem!=None){
                player.DropItem(draggedItem,true);
            }
        }
    }
    Super.DescendantRemoved(descendant);
}
