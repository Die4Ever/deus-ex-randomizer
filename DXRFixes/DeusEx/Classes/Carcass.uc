class Carcass injects DeusExCarcass;

function InitFor(Actor Other)
{
    if( Other != None ) {
        DrawScale = Other.DrawScale;
        Fatness = Other.Fatness;
    }
    
    Super.InitFor(Other);
}

function DropKeys()
{
    local Inventory item, nextItem;

    item = Inventory;
    while( item != None ) {
        nextItem = item.Inventory;
        if( item.IsA('NanoKey') || item.bDisplayableInv ) {
            DeleteInventory(item);
            class'DXRActorsBase'.static.ThrowItem(self, item);
            item.Velocity *= vect(-2, -2, 3);
        }
        item = nextItem;
    }
}

function Destroyed()
{
    DropKeys();
    Super.Destroyed();
}
