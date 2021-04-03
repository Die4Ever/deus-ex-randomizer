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
