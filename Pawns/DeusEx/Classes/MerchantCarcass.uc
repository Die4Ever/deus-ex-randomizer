class MerchantCarcass extends #var(prefix)Businessman3Carcass;

function Frob(Actor Frobber, Inventory frobWith) {
    local Inventory inv;

    for (inv = Inventory; inv != None; inv = inv.Inventory) {
        if (inv.IsA('DeusExAmmo')) {
            Spawn(inv.Class,,, Location);
        }
    }

    Super.Frob(Frobber, frobWith);
}
