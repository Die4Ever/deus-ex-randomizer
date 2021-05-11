class Carcass injects DeusExCarcass;

function InitFor(Actor Other)
{
    if( Other != None ) {
        DrawScale = Other.DrawScale;
        Fatness = Other.Fatness;
    }
    
    Super.InitFor(Other);
}

function bool _DropItem(Inventory item, Name classname)
{
    if( Ammo(item) != None )
        return false;
    else if( item.IsA(classname) && item.bDisplayableInv )
        return true;
    else
        return false;
}

function _DropItems(Name classname)
{
    local Inventory item, nextItem;

    item = Inventory;
    while( item != None ) {
        nextItem = item.Inventory;
        if( _DropItem(item, classname) ) {
            DeleteInventory(item);
            class'DXRActorsBase'.static.ThrowItem(self, item);
            item.Velocity *= vect(-2, -2, 3);
        }
        item = nextItem;
    }
}

function DropKeys()
{
    _DropItems('NanoKey');
}

function Destroyed()
{
    _DropItems('Inventory');
    Super.Destroyed();
}
