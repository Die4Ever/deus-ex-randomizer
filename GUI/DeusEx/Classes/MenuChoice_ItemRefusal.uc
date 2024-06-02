class MenuChoice_ItemRefusal extends DXRMenuUIChoiceBool;

var class<Inventory> refusedItems[6];

// does not unset refused items if disabled
static function SetRefusals()
{
    local int i;
    local class<Inventory> itemClass;

    if (default.enabled == false) return;

    for (i = 0; i < ArrayCount(default.refusedItems); i++) {
        itemClass = default.refusedItems[i];
        if (itemClass == None) continue;
            class'DXRLoadouts'.static.SetRefuseItem(itemClass);
    }
}
