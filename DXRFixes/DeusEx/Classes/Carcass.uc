class Carcass injects DeusExCarcass;

var bool dropsAmmo;

function InitFor(Actor Other)
{
    local int i;
    if( Other != None ) {
        DrawScale = Other.DrawScale;
        Fatness = Other.Fatness;
        for(i=0; i<ArrayCount(MultiSkins); i++) {
            MultiSkins[i] = Other.MultiSkins[i];
        }
        Texture = Other.Texture;
        Acceleration = Other.Acceleration;
        Velocity = Other.Velocity;
    }

    Super.InitFor(Other);
}

// HACK to fix compatibility with Lay D Denton, see Carcass2.uc
function SetMesh2(mesh m)
{
    Mesh2 = m;
}

function SetMesh3(mesh m)
{
    Mesh3 = m;
}

function bool _ShouldDropItem(Inventory item, Name classname)
{
    if( Ammo(item) != None )
        return false;
    else if( item.IsA(classname) && item.bDisplayableInv )
        return true;
    else
        return false;
}

function _DropItems(Name classname, vector offset, vector velocity)
{
    local Inventory item, nextItem;

    item = Inventory;
    while( item != None ) {
        nextItem = item.Inventory;
        if( _ShouldDropItem(item, classname) ) {
            class'DXRActorsBase'.static.ThrowItem(item, 1.0);
            item.SetLocation( item.Location + offset );
            item.Velocity *= velocity;
        }
        item = nextItem;
    }
}

function DropKeys()
{
    _DropItems('NanoKey', vect(0,0,80), vect(-0.2, -0.2, 1) );
    SetCollision(true,true,bBlockPlayers);
}

function Destroyed()
{
    _DropItems('Inventory', vect(0,0,0), vect(-2, -2, 3) );
    Super.Destroyed();
}

//Toss the item, but not very hard
function TossItem(Inventory inv, DeusExPlayer Frobber){
    local float xVel,yVel;
    local vector velocity;

    DeleteInventory(inv);
    class'DXRActorsBase'.static.ThrowItem(inv, 0.5);
    inv.SetLocation( Location + vect(0,0,20));

    velocity.X = ((FRand() - 0.5) * 2);
    velocity.Y = ((FRand() - 0.5) * 2);
    velocity.Z = 1;

    inv.Velocity *= velocity;
}

// Frob stuff...
// ----------------------------------------------------------------------
// Frob()
//
// search the body for inventory items and give them to the frobber
// ----------------------------------------------------------------------

function Frob(Actor Frobber, Inventory frobWith)
{
    local Inventory item, nextItem, startItem;
    local Pawn P;
    local bool bFoundSomething;
    local DeusExPlayer player;
    local POVCorpse corpse;

    //log("DeusExCarcass::Frob()--------------------------------");

    // Can we assume only the *PLAYER* would actually be frobbing carci?
    player = DeusExPlayer(Frobber);

    // No doublefrobbing in multiplayer.
    if (bQueuedDestroy)
        return;

    // if we've already been searched, let the player pick us up
    // don't pick up animal carcii
    if (!bAnimalCarcass)
    {
        // DEUS_EX AMSD Since we don't have animations for carrying corpses, and since it has no real use in multiplayer,
        // and since the PutInHand propagation doesn't just work, this is work we don't need to do.
        // Were you to do it, you'd need to check the respawning issue, destroy the POVcorpse it creates and point to the
        // one in inventory (like I did when giving the player starting inventory).
        if ((Inventory == None) && (player != None) && (player.inHand == None) && (Level.NetMode == NM_Standalone))
        {
            if (!bInvincible)
            {
                corpse = Spawn(class'POVCorpse');
                if (corpse != None)
                {
                    // destroy the actual carcass and put the fake one
                    // in the player's hands
                    corpse.carcClassString = String(Class);
                    corpse.KillerAlliance = KillerAlliance;
                    corpse.KillerBindName = KillerBindName;
                    corpse.Alliance = Alliance;
                    corpse.bNotDead = bNotDead;
                    corpse.bEmitCarcass = bEmitCarcass;
                    corpse.CumulativeDamage = CumulativeDamage;
                    corpse.MaxDamage = MaxDamage;
                    corpse.CorpseItemName = itemName;
                    corpse.CarcassName = CarcassName;
                    corpse.Frob(player, None);
                    corpse.SetBase(player);
                    player.PutInHand(corpse);
                    bQueuedDestroy=True;
                    Destroy();
                    return;
                }
            }
        }
    }

    bFoundSomething = False;
    bSearchMsgPrinted = False;
    P = Pawn(Frobber);
    if (P == None) return;

    // Make sure the "Received Items" display is cleared
    // DEUS_EX AMSD Don't bother displaying in multiplayer.  For propagation
    // reasons it is a lot more of a hassle than it is worth.
    if ( (player != None) && (Level.NetMode == NM_Standalone) )
        DeusExRootWindow(player.rootWindow).hud.receivedItems.RemoveItems();

    if (Inventory != None && player != None)
    {
        item = Inventory;
        startItem = item;

        do
        {
            //player.ClientMessage(self@"=> item="$item);
            nextItem = item.Inventory;
            if(TryLootItem(player, item))
                bFoundSomething = true;
            item = nextItem;
        }
        until ((item == None) || (item == startItem));
    }

    //log("  bFoundSomething = " $ bFoundSomething);

    if (!bFoundSomething)
        P.ClientMessage(msgEmpty);

    if ((player != None) && (Level.Netmode != NM_Standalone))
    {
        player.ClientMessage(Sprintf(msgRecharged, 25));

        PlaySound(sound'BioElectricHiss', SLOT_None,,, 256);

        player.Energy += 25;
        if (player.Energy > player.EnergyMax)
            player.Energy = player.EnergyMax;
    }

    Super(Carcass).Frob(Frobber, frobWith);

    if ((Level.Netmode != NM_Standalone) && (Player != None))
    {
        bQueuedDestroy = true;
        Destroy();
    }
}

function bool TryLootItem(DeusExPlayer player, Inventory item)
{
    local ammo itemAmmo, playerAmmo, newAmmo;
    local DeusExWeapon W;
    local DeusExPickup invItem;
    local int itemCount;
    local int ammoAdded, ammoLeftover, ammoPrevious;
    local DXRando dxr;
    local DXRLoadouts loadout;

    if (item.IsA('DeusExWeapon'))
    {
        // Any weapons have their ammo set to a random number of rounds (1-4)
        // unless it's a grenade, in which case we only want to dole out one.
        // DEUS_EX AMSD In multiplayer, give everything away.
        W = DeusExWeapon(item);

        // Grenades and LAMs always pickup 1
        if (W.IsA('WeaponNanoVirusGrenade') ||
            W.IsA('WeaponGasGrenade') ||
            W.IsA('WeaponEMPGrenade') ||
            W.IsA('WeaponLAM'))
            W.PickupAmmoCount = 1;
    }

    if (item.IsA('NanoKey'))
    {
        player.PickupNanoKey(NanoKey(item));
        AddReceivedItem(player, item, 1);
        DeleteInventory(item);
        item.Destroy();
        return true;
    }

    if (item.IsA('Credits'))		// I hate special cases
    {
        AddReceivedItem(player, item, Credits(item).numCredits);
        player.Credits += Credits(item).numCredits;
        player.ClientMessage(Sprintf(Credits(item).msgCreditsAdded, Credits(item).numCredits));
        DeleteInventory(item);
        item.Destroy();
        return true;
    }

    if (item.IsA('DeusExWeapon'))   // I *really* hate special cases
    {
        foreach AllActors(class'DXRando', dxr) break;
        loadout = DXRLoadouts(dxr.FindModule(class'DXRLoadouts'));
        if (loadout != None && loadout.is_banned(Weapon(item).AmmoName))
            Weapon(item).PickupAmmoCount = 0;

        // Okay, check to see if the player already has this weapon.  If so,
        // then just give the ammo and not the weapon.  Otherwise give
        // the weapon normally.
        W = DeusExWeapon(player.FindInventoryType(item.Class));

        // If the player already has this item in his inventory, piece of cake,
        // we just give him the ammo.  However, if the Weapon is *not* in the
        // player's inventory, first check to see if there's room for it.  If so,
        // then we'll give it to him normally.  If there's *NO* room, then we
        // want to give the player the AMMO only (as if the player already had
        // the weapon).

        if (W != None || (W == None && !player.FindInventorySlot(item, True)))
        {
            // Don't bother with this if there's no ammo
            if (Weapon(item).AmmoType != None && Weapon(item).PickupAmmoCount > 0)
            {
                playerAmmo = Ammo(player.FindInventoryType(Weapon(item).AmmoName));

                if (playerAmmo != None && playerAmmo.AmmoAmount < playerAmmo.MaxAmmo)
                {
                    ammoAdded = Weapon(item).PickupAmmoCount;
                    ammoLeftover=0;
                    if (playerAmmo.AmmoAmount + ammoAdded > playerAmmo.MaxAmmo){
                        ammoLeftover = (ammoAdded + playerAmmo.AmmoAmount) - playerAmmo.MaxAmmo;
                        ammoAdded = ammoAdded - ammoLeftover;
                    }
                    if (ammoLeftover > 0){
                        if(playerAmmo.Default.Mesh!=LodMesh'DeusExItems.TestBox'){
                            //Weapons with normal ammo that exists
                            newAmmo = Spawn(playerAmmo.Class,,,Location,Rotation);
                            newAmmo.ammoAmount = ammoLeftover;
                            newAmmo.Velocity = Velocity + VRand() * 280;
                        }
                    }
                    playerAmmo.AddAmmo(ammoAdded);
                    AddReceivedItem(player, playerAmmo, ammoAdded);

                    // Update the ammo display on the object belt
                    player.UpdateAmmoBeltText(playerAmmo);

                    // if this is an illegal ammo type, use the weapon name to print the message
                    if (playerAmmo.PickupViewMesh == Mesh'TestBox')
                        player.ClientMessage(item.PickupMessage @ item.itemArticle @ item.itemName, 'Pickup');
                    else
                        player.ClientMessage(playerAmmo.PickupMessage @ playerAmmo.itemArticle @ playerAmmo.itemName, 'Pickup');

                    // Mark it as 0 to prevent it from being added twice
                    Weapon(item).AmmoType.AmmoAmount = 0;
                    Weapon(item).PickupAmmoCount = 0;
                }
                else // Rando: toss the weapon just for the ammo
                {
                    player.ClientMessage(Sprintf(player.InventoryFull, item.itemName));
                    //Also toss the item out of the carcass
                    TossItem(item,player);
                    return true;
                }
            }

            // Print a message "Cannot pickup blah blah blah" if inventory is full
            // and the player can't pickup this weapon, so the player at least knows
            // if he empties some inventory he can get something potentially cooler
            // than he already has.
            if (W == None && !player.FindInventorySlot(item, True)){
                player.ClientMessage(Sprintf(player.InventoryFull, item.itemName));

                //Also toss the item out of the carcass
                TossItem(item,player);
                return true;
            }

            // Only destroy the weapon if the player already has it
            if (W != None)
            {
                // Destroy the weapon, baby!
                DeleteInventory(item);
                item.Destroy();
            }

            return true;
        }
    }

    if (item.IsA('Ammo'))
    {
        itemAmmo = Ammo(item);
        if (!dropsAmmo || itemAmmo.AmmoAmount == 0) {
            DeleteInventory(item);
            item.Destroy();
            return false;
        }

        playerAmmo = Ammo(player.FindInventoryType(item.class));

        if (playerAmmo == None) {
            ammoPrevious = 0;
        } else {
            ammoPrevious = playerAmmo.AmmoAmount;
        }
        ammoAdded = Min(itemAmmo.AmmoAmount, itemAmmo.MaxAmmo - ammoPrevious );
        ammoLeftover = itemAmmo.AmmoAmount - ammoAdded;

        if (ammoLeftover > 0) {
            newAmmo = Spawn(itemAmmo.class,,, Location);
            newAmmo.AmmoAmount = ammoLeftover;
            newAmmo.Velocity = Velocity + VRand() * 280; // same as vanilla corpse drops
        }

        if (playerAmmo == None) {
            TryLootRegularItem(player, item);
        } else {
            playerAmmo.AddAmmo(ammoAdded);

            AddReceivedItem(player, itemAmmo, ammoAdded);
            player.UpdateAmmoBeltText(playerAmmo);
            if (playerAmmo.PickupViewMesh == Mesh'TestBox') {
                player.ClientMessage(item.PickupMessage @ item.itemArticle @ item.itemName, 'Pickup');
            } else {
                player.ClientMessage(playerAmmo.PickupMessage @ playerAmmo.itemArticle @ playerAmmo.itemName, 'Pickup');
            }

            DeleteInventory(item);
            item.Destroy();
        }

        return true;
    }

    // Special case if this is a DeusExPickup(), it can have multiple copies
    // and the player already has it.

    if (item.IsA('DeusExPickup') && DeusExPickup(item).bCanHaveMultipleCopies && player.FindInventoryType(item.class) != None)
    {
        invItem   = DeusExPickup(player.FindInventoryType(item.class));
        itemCount = DeusExPickup(item).numCopies;

        // Make sure the player doesn't have too many copies
        if (invItem.MaxCopies > 0 && DeusExPickup(item).numCopies + invItem.numCopies > invItem.MaxCopies)
        {
            // Give the player the max #
            if (invItem.MaxCopies - invItem.numCopies > 0)
            {
                itemCount = (invItem.MaxCopies - invItem.numCopies);
                DeusExPickup(item).numCopies -= itemCount;
                invItem.numCopies = invItem.MaxCopies;
                player.ClientMessage(invItem.PickupMessage @ invItem.itemArticle @ invItem.itemName, 'Pickup');
                AddReceivedItem(player, invItem, itemCount);
            }
            else
            {
                player.ClientMessage(Sprintf(msgCannotPickup, invItem.itemName));
                //Also toss the item out of the carcass
                TossItem(item,player);
            }
        }
        else
        {
            invItem.numCopies += itemCount;
            DeleteInventory(item);

            player.ClientMessage(invItem.PickupMessage @ invItem.itemArticle @ invItem.itemName, 'Pickup');
            AddReceivedItem(player, invItem, itemCount);
        }
        return true;
    }

    return TryLootRegularItem(player, item);
}

function bool TryLootRegularItem(DeusExPlayer player, Inventory item)
{
    // check if the pawn is allowed to pick this up
    if (player.Inventory == None || Level.Game.PickupQuery(player, item))
    {
        player.FrobTarget = item;
        if (player.HandleItemPickup(Item) != False)
        {
            DeleteInventory(item);

            // DEUS_EX AMSD Belt info isn't always getting cleaned up.  Clean it up.
            item.bInObjectBelt=False;
            item.BeltPos=-1;

            item.SpawnCopy(player);

            // Show the item received in the ReceivedItems window and also
            // display a line in the Log
            AddReceivedItem(player, item, 1);

            player.ClientMessage(Item.PickupMessage @ Item.itemArticle @ Item.itemName, 'Pickup');
            PlaySound(Item.PickupSound);
        } else {
            TossItem(item,player);
        }
        return true;
    }
    else
    {
        DeleteInventory(item);
        item.Destroy();
        return false;
    }

    return false;
}

defaultproperties
{
    //bCollideActors=true
    //bBlockActors=true
    //bBlockPlayers=true
}
