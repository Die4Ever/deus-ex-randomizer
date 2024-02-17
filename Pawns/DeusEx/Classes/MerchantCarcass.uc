class MerchantCarcass extends #var(prefix)Businessman3Carcass;

function Frob(Actor Frobber, Inventory frobWith) {
    local Inventory inv, next;

    for (inv = Inventory; inv != None; inv = next) {
        next = inv.Inventory;
        if (inv.ItemName == "10mm Ammo") {
            Spawn(class'Ammo10mm',,, Location);
        }
    }

    Super.Frob(Frobber, frobWith);
}
