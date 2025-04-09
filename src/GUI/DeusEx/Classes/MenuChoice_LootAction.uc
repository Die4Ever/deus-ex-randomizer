class MenuChoice_LootAction extends DXRMenuUIChoiceInt;
#compileif injections

var class<Inventory> itemClasses[5];

static function SetActions()
{
    local class<Inventory> itemClass;
    local DataStorage storage;
    local int i;

    storage = class'DataStorage'.static.GetObj(class'DXRando'.default.dxr);
    for (i = 0; i < ArrayCount(default.itemClasses); i++) {
        itemClass = default.itemClasses[i];
        if (itemClass == None)
            continue;
        class'DXRLoadouts'.static.SetLootAction(itemClass, default.value, storage);
    }
}

function SaveSetting()
{
    Super.SaveSetting();
    SetActions();
}

defaultproperties
{
    value=0
    defaultvalue=0
    enumText(0)="Pick Up"
    enumText(1)="Drop"
}
