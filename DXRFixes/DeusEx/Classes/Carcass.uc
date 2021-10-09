class Carcass injects DeusExCarcass;

function InitFor(Actor Other)
{
    if( Other != None ) {
        DrawScale = Other.DrawScale;
        Fatness = Other.Fatness;
    }
    
    Super.InitFor(Other);
}

// HACK to fix compatibility with Lay D Denton, see Carcass2.uc
function SetMesh2(mesh m)
{
    log(Self$".GetMesh2("$m$"): "$Mesh2);
    Mesh2 = m;
}

function SetMesh3(mesh m)
{
    log(Self$".GetMesh3("$m$"): "$Mesh3);
    Mesh3 = m;
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
    _DropItems('NanoKey', vect(0,0,80), vect(-0.2, -0.2, 1) );
    SetCollision(true,true,bBlockPlayers);
}

function Destroyed()
{
    _DropItems('Inventory', vect(0,0,0), vect(-2, -2, 3) );
    Super.Destroyed();
}

defaultproperties
{
    //bCollideActors=true
    //bBlockActors=true
    //bBlockPlayers=true
}
