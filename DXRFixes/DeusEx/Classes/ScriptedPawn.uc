class ScriptedPawn merges ScriptedPawn;
// doesn't work with injects due to use of Self

var int flareBurnTime;

function PlayDying(name damageType, vector hitLoc)
{
    local Inventory item, nextItem;
    local bool gibbed, drop, melee;

    gibbed = (Health < -100) && !IsA('Robot');

    item = Inventory;
    while( item != None ) {
        nextItem = item.Inventory;
        melee = item.IsA('WeaponProd') || item.IsA('WeaponBaton') || item.IsA('WeaponCombatKnife') || item.Isa('WeaponCrowbar') || item.IsA('WeaponNanoSword') || item.Isa('WeaponSword');
        drop = (item.IsA('NanoKey') && gibbed) || (melee && !gibbed) || (gibbed && item.bDisplayableInv);
        if( drop ) {
            class'DXRActorsBase'.static.ThrowItem(self, item);
            item.Velocity *= vect(-1, -1, 1.3);
        }
        item = nextItem;
    }
    
    _PlayDying(damageType, hitLoc);
}

function TakeDamageBase(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType,
                        bool bPlayAnim)
{
    local name baseDamageType;
    local DeusExPlayer p;
    
    if (damageType == 'FlareFlamed') {
        baseDamageType = 'Flamed';
    } else {
        baseDamageType = damageType;
    }
    
    _TakeDamageBase(Damage,instigatedBy,hitLocation,momentum,baseDamageType,bPlayAnim);
    
    if (bBurnedToDeath) {
        p = DeusExPlayer(GetPlayerPawn());
        p.ClientMessage("Burned to death!");
        class'DXRStats'.static.AddBurnKill(p);
    } 
    
    if (damageType == 'FlareFlamed') {
        flareBurnTime = 3;
    }
}

function UpdateFire()
{
    _UpdateFire();
    if (flareBurnTime > 0) {
        flareBurnTime -= 1;
        if (flareBurnTime == 0) {
            ExtinguishFire();
        }
    }
}
