class ScriptedPawn merges ScriptedPawn;
// doesn't work with injects due to use of Self
function Carcass SpawnCarcass()
{
    local Inventory item, nextItem;
    local bool gibbed, drop, melee;

    gibbed = (Health < -100) && !IsA('Robot');

    item = Inventory;
    while( item != None ) {
        nextItem = item.Inventory;
        melee = item.IsA('WeaponProd') || item.IsA('WeaponBaton') || item.IsA('WeaponCombatKnife') || item.Isa('WeaponCrowbar') || item.IsA('WeaponNanoSword') || item.Isa('WeaponSword');
        drop = (item.IsA('NanoKey') && gibbed) || (melee && !gibbed);//don't give the melee weapon if we're getting gibbed, that would make the game easier and this is supposed to be a QoL change not a balance change
        if( drop ) {
            DeleteInventory(item);
            item.DropFrom(Location);
        }
        item = nextItem;
    }
    
    return _SpawnCarcass();
}
