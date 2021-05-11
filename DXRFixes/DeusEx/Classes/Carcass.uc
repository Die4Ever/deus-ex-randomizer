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

function _DropItems(Name classname, vector offset, vector velocity)
{
    local Inventory item, nextItem;

    item = Inventory;
    while( item != None ) {
        nextItem = item.Inventory;
        if( _DropItem(item, classname) ) {
            DeleteInventory(item);
            class'DXRActorsBase'.static.ThrowItem(self, item);
            item.SetLocation( item.Location + offset );
            item.Velocity *= velocity;
        }
        item = nextItem;
    }
}

function DropKeys()
{
    _DropItems('NanoKey', vect(0,0,80), vect(0, 0, 0) );
}

function Destroyed()
{
    _DropItems('Inventory', vect(0,0,0), vect(-2, -2, 3) );
    Super.Destroyed();
}

defaultproperties
{
    bCollideActors=true
    bBlockActors=true
    bBlockPlayers=true
}
