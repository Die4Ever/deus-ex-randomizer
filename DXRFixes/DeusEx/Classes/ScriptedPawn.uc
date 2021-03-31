class ScriptedPawn merges ScriptedPawn;
// doesn't work with injects, because of states and : Error, DeusEx.ScriptedPawn's superclass must be Engine.Pawn, not DeusEx.ScriptedPawnBase
// could work with injectsabove or whatever https://github.com/Die4Ever/deus-ex-randomizer/issues/115
var int flareBurnTime;

function PlayDying(name damageType, vector hitLoc)
{
    local DeusExPlayer p;
    local Inventory item, nextItem;
    local bool gibbed, drop, melee;

    gibbed = (Health < -100) && !IsA('Robot');

    if( gibbed ) {
        p = DeusExPlayer(GetPlayerPawn());
        class'DXRStats'.static.AddGibbedKill(p);
    }

    item = Inventory;
    while( item != None ) {
        nextItem = item.Inventory;
        melee = item.IsA('WeaponProd') || item.IsA('WeaponBaton') || item.IsA('WeaponCombatKnife') || item.Isa('WeaponCrowbar') || item.IsA('WeaponNanoSword') || item.Isa('WeaponSword');
        drop = (item.IsA('NanoKey') && gibbed) || (melee && !gibbed) || (gibbed && item.bDisplayableInv);
        if( DeusExWeapon(item) != None && DeusExWeapon(item).bNativeAttack )
            drop = false;
        if( Ammo(item) != None )
            drop = false;
        if( drop ) {
            class'DXRActorsBase'.static.ThrowItem(self, item);
            if(gibbed)
                item.Velocity *= vect(-2, -2, 2);
            else
                item.Velocity *= vect(-1.5, -1.5, 1.5);
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
