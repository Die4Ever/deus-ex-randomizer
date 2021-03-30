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
    local bool drop;

    item = Inventory;
    while( item != None ) {
        nextItem = item.Inventory;
        drop = item.IsA('NanoKey') || item.bDisplayableInv;
        if( Ammo(item) != None ) drop = false;
        if( drop ) {
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
