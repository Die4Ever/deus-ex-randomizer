class ChargedPickup merges ChargedPickup;
// need to figure out states compatibility https://github.com/Die4Ever/deus-ex-randomizer/issues/135

function ChargedPickupBegin(DeusExPlayer Player)
{
    local Human p;
    if(bOneUseOnly) {
        bDisplayableInv = false;
        p = Human(Owner);
        if( p != None ) {
            p.HideInventory(self);
        }
    }
    _ChargedPickupBegin(Player);
}

simulated function int CalcChargeDrain(DeusExPlayer Player)
{
    local int drain;

    drain = _CalcChargeDrain(Player);
    if( drain < 1 ) drain = 1;
    return drain;
}

// overriding the Pickup class's function returning true, we return false in order to allow the pickup to happen
// if we don't do this, then Pickup will return true because bDisplayableInv is false
function bool HandlePickupQuery( inventory Item )
{
    if ( Item.Class == Class )
        return false;
    return Super.HandlePickupQuery(Item);
}
