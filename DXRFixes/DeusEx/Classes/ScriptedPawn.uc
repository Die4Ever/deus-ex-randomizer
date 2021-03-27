class ScriptedPawn merges ScriptedPawn;
// doesn't work with injects due to use of Self

function PlayDying(name damageType, vector hitLoc)
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
            class'DXRActorsBase'.static.ThrowItem(self, item);
            item.Velocity *= vect(-1, -1, 1.3);
        }
        item = nextItem;
    }
    
    _PlayDying(damageType, hitLoc);
}
