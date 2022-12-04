//LDDP already injects, so we're basically forced to do injects as well
class DXRConPlayBase injects ConPlayBase;


// ----------------------------------------------------------------------
// SetupEventTransferObject()
//
// Gives a Pawn the specified object.  The object will be created out of
// thin air (spawned) if there's no "fromActor", otherwise it's
// transfered from one pawn to another.
//
// We now allow this to work without the From actor, which can happen
// in InfoLinks, since the FromActor may not even be on the map.
// This is useful for tranferring DataVaultImages.
// ----------------------------------------------------------------------

function EEventAction SetupEventTransferObject( ConEventTransferObject event, out String nextLabel )
{
	local EEventAction nextAction;
	local Inventory invItemFrom;
	local Inventory invItemTo;
	local ammo AmmoType;
	local bool bSpawnedItem;
	local bool bSplitItem;
	local int itemsTransferred;

/*
log("SetupEventTransferObject()------------------------------------------");
log("  event = " $ event);
log("  event.giveObject = " $ event.giveObject);
log("  event.fromActor  = " $ event.fromActor );
log("  event.toActor    = " $ event.toActor );
*/
	itemsTransferred = 1;

	if ( event.failLabel != "" )
	{
		nextAction = EA_JumpToLabel;
		nextLabel  = event.failLabel;
	}
	else
	{
		nextAction = EA_NextEvent;
		nextLabel = "";
	}

	// First verify that the receiver exists!
	if (event.toActor == None)
	{
		log("SetupEventTransferObject:  WARNING!  toActor does not exist!");
		log("  Conversation = " $ con.conName);
		return nextAction;
	}

	// First, check to see if the giver actually has the object.  If not, then we'll
	// fabricate it out of thin air.  (this is useful when we want to allow
	// repeat visits to the same NPC so the player can restock on items in some
	// scenarios).
	//
	// Also check to see if the item already exists in the recipient's inventory
	if (event.fromActor != None)
		invItemFrom = Pawn(event.fromActor).FindInventoryType(event.giveObject);

	invItemTo   = Pawn(event.toActor).FindInventoryType(event.giveObject);

//log("  invItemFrom = " $ invItemFrom);
//log("  invItemTo   = " $ invItemTo);

	// If the player is doing the giving, make sure we remove it from
	// the object belt.

	// If the giver doesn't have the item then we must spawn a copy of it
	if (invItemFrom == None)
	{
		invItemFrom = Spawn(event.giveObject);
		bSpawnedItem = True;
	}

	// If we're giving this item to the player and he does NOT yet have it,
	// then make sure there's enough room in his inventory for the
	// object!

	if ((invItemTo == None) &&
		(DeusExPlayer(event.toActor) != None) &&
	    (DeusExPlayer(event.toActor).FindInventorySlot(invItemFrom, True) == False))
	{
		// First destroy the object if we previously Spawned it
		if (bSpawnedItem)
			invItemFrom.Destroy();

		return nextAction;
	}

	// Okay, there's enough room in the player's inventory or we're not
	// transferring to the player in which case it doesn't matter.
	//
	// Now check if the recipient already has the item.  If so, we are just
	// going to give it to him, with a few special cases.  Otherwise we
	// need to spawn a new object.

	if (invItemTo != None)
	{
		// Check if this item was in the player's hand, and if so, remove it
		RemoveItemFromPlayer(invItemFrom);

		// If this is ammo, then we want to just increment the ammo count
		// instead of adding another ammo to the inventory

		if (invItemTo.IsA('Ammo'))
		{
			// If this is Ammo and the player already has it, make sure the player isn't
			// already full of this ammo type! (UGH!)
			//if (!Ammo(invItemTo).AddAmmo(Ammo(invItemFrom).AmmoAmount))
			//{
			//	invItemFrom.Destroy();
			//	return nextAction;
			//}

			//RANDO: We'll just let it slide if you have max ammo.
			Ammo(invItemTo).AddAmmo(Ammo(invItemFrom).AmmoAmount);

			// Destroy our From item
			invItemFrom.Destroy();
		}

		// Pawn cannot have multiple weapons, but we do want to give the
		// player any ammo from the weapon
		else if ((invItemTo.IsA('Weapon')) && (DeusExPlayer(event.ToActor) != None))
		{
			AmmoType = Ammo(DeusExPlayer(event.ToActor).FindInventoryType(Weapon(invItemTo).AmmoName));

			if ( AmmoType != None )
			{
				// Special case for Grenades and LAMs.  Blah.
				if ((AmmoType.IsA('AmmoEMPGrenade')) ||
				    (AmmoType.IsA('AmmoGasGrenade')) ||
					(AmmoType.IsA('AmmoNanoVirusGrenade')) ||
					(AmmoType.IsA('AmmoLAM')))
				{
					if (!AmmoType.AddAmmo(event.TransferCount))
					{
						invItemFrom.Destroy();
						return nextAction;
					}
				}
				else
				{
					if (!AmmoType.AddAmmo(Weapon(invItemTo).PickUpAmmoCount))
					{
						invItemFrom.Destroy();
						return nextAction;
					}

					event.TransferCount = Weapon(invItemTo).PickUpAmmoCount;
					itemsTransferred = event.TransferCount;
				}

				if (event.ToActor.IsA('DeusExPlayer'))
					DeusExPlayer(event.ToActor).UpdateAmmoBeltText(AmmoType);

				// Tell the player he just received some ammo!
				invItemTo = AmmoType;
			}
			else
			{
				// Don't want to show this as being received in a convo
				invItemTo = None;
			}

			// Destroy our From item
			invItemFrom.Destroy();
			invItemFrom = None;
		}

		// Otherwise check to see if we need to transfer more than
		// one of the given item
		else
		{
			itemsTransferred = AddTransferCount(invItemFrom, invItemTo, event, Pawn(event.toActor), False);

			// If no items were transferred, then the player's inventory is full or
			// no more of these items can be stacked, so abort.
			if (itemsTransferred == 0){
				if (bSpawnedItem){
					invItemFrom.Destroy();
				}
				return nextAction;
			}

			// Now destroy the originating object (which we either spawned
			// or is sitting in the giver's inventory), but check to see if this
			// item still has any copies left first

			if (((invItemFrom.IsA('DeusExPickup')) && (DeusExPickup(invItemFrom).bCanHaveMultipleCopies) && (DeusExPickup(invItemFrom).NumCopies <= 0)) ||
			   ((invItemFrom.IsA('DeusExPickup')) && (!DeusExPickup(invItemFrom).bCanHaveMultipleCopies)) ||
			   (!invItemFrom.IsA('DeusExPickup')))
			{
				invItemFrom.Destroy();
				invItemFrom = None;
			}
		}
	}

	// Okay, recipient does *NOT* have the item, so it must be give
	// to that pawn and the original destroyed
	else
	{
		// If the item being given is a stackable item and the
		// recipient isn't receiving *ALL* the copies, then we
		// need to spawn a *NEW* copy and give that to the recipient.
		// Otherwise just do a "SpawnCopy", which transfers ownership
		// of the object to the new owner.

		if ((invItemFrom.IsA('DeusExPickup')) && (DeusExPickup(invItemFrom).bCanHaveMultipleCopies) &&
		    (DeusExPickup(invItemFrom).NumCopies > event.transferCount))
		{
			itemsTransferred = event.TransferCount;
			invItemTo = Spawn(event.giveObject);
			invItemTo.GiveTo(Pawn(event.toActor));
			DeusExPickup(invItemFrom).NumCopies -= event.transferCount;
			bSplitItem   = True;
			bSpawnedItem = True;
		}
		else
		{
			invItemTo = invItemFrom.SpawnCopy(Pawn(event.toActor));
		}

//log("  invItemFrom = "$  invItemFrom);
//log("  invItemTo   = " $ invItemTo);

		if (DeusExPlayer(event.toActor) != None)
			DeusExPlayer(event.toActor).FindInventorySlot(invItemTo);

		// Check if this item was in the player's hand *AND* that the player is
		// giving the item to someone else.
		if ((DeusExPlayer(event.fromActor) != None) && (!bSplitItem))
			RemoveItemFromPlayer(invItemFrom);

		// If this was a DataVaultImage, then the image needs to be
		// properly added to the datavault
		if ((invItemTo.IsA('DataVaultImage')) && (event.toActor.IsA('DeusExPlayer')))
		{
			DeusExPlayer(event.toActor).AddImage(DataVaultImage(invItemTo));

			if (conWinThird != None)
				conWinThird.ShowReceivedItem(invItemTo, 1);
			else
				DeusExRootWindow(player.rootWindow).hud.receivedItems.AddItem(invItemTo, 1);

			invItemFrom = None;
			invItemTo   = None;
		}

		// Special case for Credit Chits also
		else if ((invItemTo.IsA('Credits')) && (event.toActor.IsA('DeusExPlayer')))
		{
			if (conWinThird != None)
				conWinThird.ShowReceivedItem(invItemTo, Credits(invItemTo).numCredits);
			else
				DeusExRootWindow(player.rootWindow).hud.receivedItems.AddItem(invItemTo, Credits(invItemTo).numCredits);

			player.Credits += Credits(invItemTo).numCredits;

			invItemTo.Destroy();

			invItemFrom = None;
			invItemTo   = None;
		}

		// Now check to see if the transfer event specified transferring
		// more than one copy of the object
		else
		{
			itemsTransferred = AddTransferCount(invItemFrom, invItemTo, event, Pawn(event.toActor), True);
			// If no items were transferred, then the player's inventory is full or
			// no more of these items can be stacked, so abort.
			if (itemsTransferred == 0)
			{
				invItemTo.Destroy();
				return nextAction;
			}

			// Update the belt text
			if (invItemTo.IsA('Ammo'))
				player.UpdateAmmoBeltText(Ammo(invItemTo));
			else
				player.UpdateBeltText(invItemTo);
		}
	}

	// Show the player that he/she/it just received something!
	if ((DeusExPlayer(event.toActor) != None) && (conWinThird != None) && (invItemTo != None))
	{
		if (conWinThird != None)
			conWinThird.ShowReceivedItem(invItemTo, itemsTransferred);
		else
			DeusExRootWindow(player.rootWindow).hud.receivedItems.AddItem(invItemTo, itemsTransferred);
	}

	nextAction = EA_NextEvent;
	nextLabel = "";

	return nextAction;
}

// ---------------------------------------------------------------------
// AddTransferCount()
// ----------------------------------------------------------------------

function int AddTransferCount(
	Inventory invItemFrom,
	Inventory invItemTo,
	ConEventTransferObject event,
	pawn transferTo,
	bool bSpawned)
{
	local ammo AmmoType;
	local int itemsTransferred;
	local DeusExPickup giveItem;

	itemsTransferred = 1;
/*
log("AddTransferCount()-------------------------------");
log("  invItemFrom = " $ invItemFrom);
log("  invItemTo   = " $ invItemTo);
log("  transferTo  = " $ transferTo);
log("  bSpawned    = " $ bSpawned);
log("  event.transferCount = " $ event.transferCount);
*/
	if (invItemTo == None)
		return 0;

	// If this is a Weapon, then we need to just add additional
	// ammo.
	if (invItemTo.IsA('Weapon'))
	{
		if (event.transferCount > 1)
		{
			AmmoType = Ammo(transferTo.FindInventoryType(Weapon(invItemTo).AmmoName));

			if ( AmmoType != None )
			{
				itemsTransferred = Weapon(invItemTo).PickUpAmmoCount * (event.transferCount - 1);
				AmmoType.AddAmmo(itemsTransferred);

				// For count displayed
				itemsTransferred++;
			}
		}
	}

	// If this is a DeusExPickup and he already has it, just
	// increment the count
	else if ((invItemTo.IsA('DeusExPickup')) && (DeusExPickup(invItemTo).bCanHaveMultipleCopies))
	{
		// If the item was spawned, then it will already have a copy count of 1, so we
		// only want to add to that if it was specified to transfer > 1 items.

		if (bSpawned)
		{
			if (event.transferCount > 1)
			{
				//RANDO: Only allow the transfer if the recipient can hold all of the items being transferred simultaneously
				if ((DeusExPickup(invItemTo).NumCopies + event.transferCount) > DeusExPickup(invItemTo).maxCopies){
					itemsTransferred = 0;
				} else {
					//Minus one because we are incrementing the number of copies before giving the single actual item to be transferred
					//This is goofy, but seems to just be how it was done
					DeusExPickup(invItemTo).NumCopies += event.transferCount - 1;
					itemsTransferred = event.transferCount;
				}
			}

		// Wasn't spawned, so add the appropriate amount (if transferCount
		// isn't specified, just add one).
		}
		else
		{
			if (event.transferCount > 0)
				itemsTransferred = event.transferCount;
			else
				itemsTransferred = 1;

			if ((DeusExPickup(invItemTo).NumCopies + itemsTransferred) > DeusExPickup(invItemTo).MaxCopies){
				itemsTransferred = 0;
			} else {
				DeusExPickup(invItemTo).NumCopies += itemsTransferred;

				if ((DeusExPickup(invItemFrom) != None) && (invItemFrom != InvItemTo)){
					DeusExPickup(invItemFrom).NumCopies -= itemsTransferred;
				}
			}
		}

		// Update the belt text
		DeusExPickup(invItemTo).UpdateBeltText();
	}
	else if ((invItemTo.IsA('DeusExPickup')) && (!bSpawned))
	{
		giveItem = DeusExPickup(Spawn(invItemTo.Class));
		giveItem.GiveTo(transferTo);

		// Just give the player another one of these fucking things
		if ((DeusExPlayer(transferTo) != None) && (DeusExPlayer(transferTo).FindInventorySlot(giveItem)))
			itemsTransferred = 1;
		else
			itemsTransferred = 0;
	}

//log("  return itemsTransferred = " $ itemsTransferred);

	return itemsTransferred;
}
