class MenuChoice_ItemRefusal extends DXRMenuUIChoiceInt;
#compileif injections

var class<Inventory> refusedItems[6];

static function SetRefusals()
{
    local int i;
    local class<Inventory> itemClass;

    for (i = 0; i < ArrayCount(default.refusedItems); i++) {
        itemClass = default.refusedItems[i];
        if (itemClass == None) continue;

        if (default.value == 0) {
            class'DXRLoadouts'.static.UnsetRefuseItem(itemClass);
            class'DXRLoadouts'.static.UnsetAutoconsumedItem(class<DeusExPickup>(itemClass));
        }
        else if (default.value == 1) {
            class'DXRLoadouts'.static.SetRefuseItem(itemClass);
            class'DXRLoadouts'.static.UnsetAutoconsumedItem(class<DeusExPickup>(itemClass));
        } else if (default.value == 2) {
            class'DXRLoadouts'.static.SetRefuseItem(itemClass); // when there's no benefit to consuming the item, drop it instead
            class'DXRLoadouts'.static.SetAutoconsumedItem(class<DeusExPickup>(itemClass));
        }
    }
}

function SaveSetting()
{
    Super.SaveSetting();
    SetRefusals();
}

defaultproperties
{
    value=0
    defaultvalue=0
    enumText(0)="Pick Up"
    enumText(1)="Drop"
}
