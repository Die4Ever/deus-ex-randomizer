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
    }
}
