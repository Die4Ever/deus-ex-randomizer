Class DXRAmmo injects #var(DeusExPrefix)Ammo;

function bool HandlePickupQuery( inventory Item )
{
    local Ammo ownedAmmo,thisAmmo;
    local int ammoToAdd,ammoRemaining;
    local DeusExPlayer player;
    local DXRLoadouts loadout;
    local bool ammoBanned;

    thisAmmo = Ammo(Item);
    player = DeusExPlayer(Owner);

    loadout = DXRLoadouts(class'DXRLoadouts'.static.Find());
    ammoBanned=False;
    if (loadout!=None){
        ammoBanned = loadout.is_banned(Item.Class);
    }
    if (ammoBanned){
        return True;
    }

    if (thisAmmo!=None && player!=None && Item.Class == Class && thisAmmo.AmmoAmount > 0){
        ownedAmmo = Ammo(player.FindInventoryType(thisAmmo.Class));
        if (ownedAmmo!=None){
            ammoToAdd = thisAmmo.AmmoAmount;
            ammoRemaining=0;
            if ((ammoToAdd + ownedAmmo.AmmoAmount) > ownedAmmo.MaxAmmo){
                ammoRemaining = (ammoToAdd + ownedAmmo.AmmoAmount) - ownedAmmo.MaxAmmo;
                ammoToAdd = ammoToAdd - ammoRemaining;
            }
            thisAmmo.itemArticle = string(ammoToAdd);

            if (ammoRemaining>0){
                thisAmmo.ammoAmount = ammoRemaining;
                AddAmmo(ammoToAdd);
                player.ClientMessage(Item.PickupMessage @ Item.itemArticle @ Item.ItemName, 'Pickup');
                return True;
            }
        } else {
            item.itemArticle = string(thisAmmo.AmmoAmount);
        }
    }

    return Super.HandlePickupQuery(Item);
}
