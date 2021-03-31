class ChargedPickup merges ChargedPickup;
// need to figure out states compatibility https://github.com/Die4Ever/deus-ex-randomizer/issues/135

function ChargedPickupBegin(DeusExPlayer Player)
{
    local DeusExPlayer p;
    if(bOneUseOnly) {
        bDisplayableInv = false;
        p = DeusExPlayer(Owner);
        if( p != None ) {
            p.DeleteInventory(self);
            Inventory = p.Inventory;
            p.Inventory = self;
        }
    }
    _ChargedPickupBegin(Player);
}
