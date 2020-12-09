class DXRPlayer merges DeusExPlayer;

function bool AddInventory( inventory NewItem )
{
    local DXRBannedItems ban_items;

    foreach AllActors(class'DXRBannedItems', ban_items) {
        if ( ban_items.ban(self, NewItem) ) return true;
    }
    return _AddInventory(NewItem);
}
