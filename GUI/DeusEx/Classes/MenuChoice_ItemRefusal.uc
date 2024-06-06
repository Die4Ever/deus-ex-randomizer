class MenuChoice_ItemRefusal extends DXRMenuUIChoiceBool;
#compileif injections

var class<Inventory> refusedItems[6];

static function SetRefusals()
{
    local int i;
    local class<Inventory> itemClass;

    for (i = 0; i < ArrayCount(default.refusedItems); i++) {
        itemClass = default.refusedItems[i];
        if (itemClass == None) continue;

        if (default.enabled)
            class'DXRLoadouts'.static.SetRefuseItem(itemClass);
        else
            class'DXRLoadouts'.static.UnsetRefuseItem(itemClass);
    }
}

function SaveSetting()
{
    Super.SaveSetting();
    SetRefusals();
}
