Class DXRAmmo injects #var(DeusExPrefix)Ammo;

// Name to be used in pickup messages, because "You found 12 Plasma Clip" is a bad message
var() string ItemPickupName;

function bool HandlePickupQuery( inventory Item )
{
    local #var(DeusExPrefix)Ammo ownedAmmo,thisAmmo;
    local int ammoToAdd,ammoRemaining;
    local DeusExPlayer player;
    local DXRLoadouts loadout;
    local bool ammoBanned;

    thisAmmo = #var(DeusExPrefix)Ammo(Item);
    player = DeusExPlayer(Owner);

    loadout = DXRLoadouts(class'DXRLoadouts'.static.Find());
    ammoBanned=False;
    if (loadout!=None){
        ammoBanned = loadout.is_banned(Item.Class);
    }
    if (ammoBanned){
        return True;
    }

    if (thisAmmo!=None && player!=None  && Item.Class == Class && thisAmmo.AmmoAmount > 0){
        ownedAmmo = #var(DeusExPrefix)Ammo(player.FindInventoryType(thisAmmo.Class));
        if (ownedAmmo!=None){
            ammoToAdd = thisAmmo.AmmoAmount;
            ammoRemaining=0;
            if ((ammoToAdd + ownedAmmo.AmmoAmount) > ownedAmmo.MaxAmmo){
                ammoRemaining = (ammoToAdd + ownedAmmo.AmmoAmount) - ownedAmmo.MaxAmmo;
                ammoToAdd = ammoToAdd - ammoRemaining;
            }

            if (ammoRemaining>0){
                thisAmmo.ammoAmount = ammoRemaining;
                AddAmmo(ammoToAdd);
                player.ClientMessage(thisAmmo.PickupString(ammoToAdd), 'Pickup');
                return True;
            }
        }

    }

    return Super.HandlePickupQuery(Item);
}

function string GetPickupName()
{
    if (ItemPickupName == "")
        return ItemName;
    return ItemPickupName;
}

function string PickupString(int amount)
{
    return PickupMessage @ amount @ GetPickupName();
}

auto state Pickup
{
    function Frob(Actor Other, Inventory frobWith)
	{
        local string backupArticle, backupName;

        backupArticle = ItemArticle;
        backupName = ItemName;

        ItemArticle = string(AmmoAmount);
        ItemName = GetPickupName();

        Super.Frob(Other, frobWith);

        ItemArticle = backupArticle;
        ItemName = backupName;
	}
}
