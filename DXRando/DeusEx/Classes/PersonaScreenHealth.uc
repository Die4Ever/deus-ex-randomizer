class DXRPersonaScreenHealth merges PersonaScreenHealth;

function int ApplyGeneralHealing(int healAmount)
{
	local int    pointsHealed;
	local int    regionIndex;
	local float  damageAmount;
	local bool   bPartDamaged;
    local int    healPointsRemaining;

    healPointsRemaining = healAmount;
	// Loop through all the parts repeatedly until
	// we either:
	//
	// A) Run out of parts to heal or
	// B) Run out of points to distribute.
	while(healPointsRemaining > 0)
	{
		bPartDamaged = False;

		// Loop through all the parts
		for(regionIndex=0; regionIndex<arrayCount(regionWindows); regionIndex++)
		{
			damageAmount = regionWindows[regionIndex].maxHealth - regionWindows[regionIndex].currentHealth;

			if ((damageAmount > 0) && (healPointsRemaining > 0))
			{
				// Heal this part
				pointsHealed += HealPart(regionWindows[regionIndex], 1, True);

				healPointsRemaining--;
				bPartDamaged = True;
			}
		}

		if (!bPartDamaged)
			break;
	}

    return pointsHealed;
}

// ----------------------------------------------------------------------
// HealAllParts()
//
// Uses as many medkits as possible to heal as much damage.  Health
// points are distributed evenly among parts
// ----------------------------------------------------------------------
function int HealAllParts()
{
	local MedKit medkit;
	local int    healPointsAvailable;
	local int    healPointsRemaining;
	local int    pointsHealed;

	pointsHealed = 0;
	PushHealth();

	// First determine how many medkits the player has
	healPointsAvailable = GetMedKitHealPoints();
	healPointsRemaining = healPointsAvailable;

	// Apply healing to all body parts
    pointsHealed = ApplyGeneralHealing(healPointsRemaining);

	// Now remove any medkits we may have used
	RemoveMedKits(pointsHealed);

	player.PopHealth( playerHealth[0],playerHealth[1],playerHealth[2],playerHealth[3],playerHealth[4],playerHealth[5]);

	EnableButtons();

	winStatus.AddText(Sprintf(PointsHealedLabel, pointsHealed));

	return pointsHealed;
}


// ----------------------------------------------------------------------
// HealPart()
//
// Returns the amount of damage healed
// ----------------------------------------------------------------------

function int HealPart(PersonaHealthRegionWindow region, optional float pointsToHeal, optional bool bLeaveMedKit)
{
	local float healthAdded;
	local float newHealth;
    local float remaining;
	local medKit medKit;
    local int i;
    local bool wasSpecificAmount;

	// First make sure the player has a medkit
	medKit = MedKit(player.FindInventoryType(Class'MedKit'));

	if ((region == None) || (medKit == None))
		return 0;

	// If a point value was passed in, use it as the amount of
	// points to heal for this body part.  Otherwise use the
	// medkit's default heal amount.

	if (pointsToHeal == 0)
		pointsToHeal = player.CalculateSkillHealAmount(medKit.healAmount);
    else
        wasSpecificAmount = True;

	// Heal the selected body part by the number of
	// points available in the part


	// If our player is in a multiplayer game, heal across 3 hit locations
	if ( player.PlayerIsClient() )
	{
		switch(region.GetPartIndex())
		{
			case 0:		// head
				newHealth = FMin(playerHealth[0] + pointsToHeal, player.default.HealthHead);
				healthAdded = newHealth - playerHealth[0];
				playerHealth[0] = newHealth;
				break;

			case 1:		// torso, right arm, left arm
			case 2:
			case 3:
				pointsToHeal *= 0.333;	// Divide heal points among parts
				newHealth = FMin(playerHealth[1] + pointsToHeal, player.default.HealthTorso);
				healthAdded = newHealth - playerHealth[1];
				playerHealth[1] = newHealth;
				regionWindows[1].SetHealth(newHealth);
				newHealth = FMin(playerHealth[2] + pointsToHeal, player.default.HealthArmRight);
				healthAdded = newHealth - playerHealth[2];
				playerHealth[2] = newHealth;
				regionWindows[2].SetHealth(newHealth);
				newHealth = FMin(playerHealth[3] + pointsToHeal, player.default.HealthArmLeft);
				healthAdded = newHealth - playerHealth[3];
				playerHealth[3] = newHealth;
				regionWindows[3].SetHealth(newHealth);
				break;
			case 4:		// right leg, left leg
			case 5:
				pointsToHeal *= 0.5;		// Divide heal points among parts
				newHealth = FMin(playerHealth[4] + pointsToHeal, player.default.HealthLegRight);
				healthAdded = newHealth - playerHealth[4];
				playerHealth[4] = newHealth;
				regionWindows[4].SetHealth(newHealth);
				newHealth = FMin(playerHealth[5] + pointsToHeal, player.default.HealthLegLeft);
				healthAdded = newHealth - playerHealth[5];
				playerHealth[5] = newHealth;
				regionWindows[5].SetHealth(newHealth);
				break;
		}
	}
	else
	{
		switch(region.GetPartIndex())
		{
			case 0:		// head
				newHealth = FMin(playerHealth[0] + pointsToHeal, player.default.HealthHead);
				healthAdded = newHealth - playerHealth[0];
				playerHealth[0] = newHealth;
				break;

			case 1:		// torso
				newHealth = FMin(playerHealth[1] + pointsToHeal, player.default.HealthTorso);
				healthAdded = newHealth - playerHealth[1];
				playerHealth[1] = newHealth;
				break;

			case 2:		// right arm
				newHealth = FMin(playerHealth[2] + pointsToHeal, player.default.HealthArmRight);
				healthAdded = newHealth - playerHealth[2];
				playerHealth[2] = newHealth;
				break;

			case 3:		// left arm
				newHealth = FMin(playerHealth[3] + pointsToHeal, player.default.HealthArmLeft);
				healthAdded = newHealth - playerHealth[3];
				playerHealth[3] = newHealth;
				break;

			case 4:		// right leg
				newHealth = FMin(playerHealth[4] + pointsToHeal, player.default.HealthLegRight);
				healthAdded = newHealth - playerHealth[4];
				playerHealth[4] = newHealth;
				break;

			case 5:		// left leg
				newHealth = FMin(playerHealth[5] + pointsToHeal, player.default.HealthLegLeft);
				healthAdded = newHealth - playerHealth[5];
				playerHealth[5] = newHealth;
				break;
		}
	}

    //Push any remaining healing from the medkit to other parts, if not being called from HealAllParts
    if (!wasSpecificAmount){
        remaining = pointsToHeal - healthAdded;
        healthAdded+=ApplyGeneralHealing(remaining);
    }

    //Put all the health values back in the player
	player.PopHealth( playerHealth[0],playerHealth[1],playerHealth[2],playerHealth[3],playerHealth[4],playerHealth[5]);

    //Update all the health bars in the health window
    for (i=0;i<ArrayCount(regionWindows);i++){
        regionWindows[i].SetHealth(playerHealth[i]);
    }
	// Remove the item from the player's invenory and this screen
	if (!bLeaveMedKit)
		UseMedKit(medkit);

	return healthAdded;
}

function bool ButtonActivated(Window buttonPressed)
{
	local bool bHandled;
	local int  pointsHealed;

	if (Super.ButtonActivated(buttonPressed))
		return True;

	bHandled   = True;

	// Check if this is one of our Augmentation buttons
	if (buttonPressed.IsA('PersonaHealthItemButton'))
	{
		SelectHealth(PersonaHealthItemButton(buttonPressed));
	}
	else if (buttonPressed.IsA('PersonaHealthActionButtonWindow'))
	{
		PushHealth();
		pointsHealed = HealPart(regionWindows[PersonaHealthActionButtonWindow(buttonPressed).GetPartIndex()]);
		player.PopHealth( playerHealth[0],playerHealth[1],playerHealth[2],playerHealth[3],playerHealth[4],playerHealth[5]);
		winStatus.AddText(Sprintf(PointsHealedLabel, pointsHealed));

		EnableButtons();
	}
	else if (buttonPressed.GetParent().IsA('PersonaHealthRegionWindow'))
	{
		partButtons[PersonaHealthRegionWindow(buttonPressed.GetParent()).GetPartIndex()].PressButton(IK_None);
	}
	else
	{
		switch(buttonPressed)
		{
			case btnHealAll:
				//HealAllParts();
                MakeHealAllConfirmationWindow();
				break;

			default:
				bHandled = False;
				break;
		}
	}

	return bHandled;
}

function float FindTotalDamage()
{
	local int    regionIndex;
	local float  damageAmount;

    damageAmount = 0;
    for(regionIndex=0; regionIndex<arrayCount(regionWindows); regionIndex++)
    {
        damageAmount = damageAmount + (regionWindows[regionIndex].maxHealth - regionWindows[regionIndex].currentHealth);
    }

    return damageAmount;

}

function int Ceil(float f)
{
    local int ret;
    ret = f;
    if( float(ret) < f )
        ret++;
    return ret;
}

function MakeHealAllConfirmationWindow()
{
    local String title;
    local String mainText;
    local int numMedkitsConsumed,numMedkitsAvail;
    local float medkitHealAmount, totalDamage;
    local MedKit medkit;

  	medKit = MedKit(player.FindInventoryType(Class'MedKit'));
	if (medKit != None) {
		numMedkitsAvail = medKit.NumCopies;
        medkitHealAmount = player.CalculateSkillHealAmount(medKit.healAmount);
	} else {
		numMedkitsAvail = 0;
    }

    totalDamage = FindTotalDamage();

    numMedkitsConsumed = Ceil(totalDamage/medkitHealAmount);

    title = "Heal All?";
    mainText = "Are you sure you want to heal all?";

    if (numMedkitsConsumed < numMedkitsAvail){
        if (numMedkitsConsumed==1){
           mainText = mainText$" This will use 1 medkit!";
        } else {
           mainText = mainText$" This will use "$numMedkitsConsumed$" medkits!";
        }
    } else if (numMedkitsConsumed == numMedkitsAvail){
       mainText = mainText$" This will use all your medkits!";
    } else if (numMedkitsConsumed > numMedkitsAvail){
       mainText = mainText$" This will use all your medkits and you still won't have full health!";
    }

    root.MessageBox(title,mainText,0,False,Self);

}

event bool BoxOptionSelected(Window msgBoxWindow, int buttonNumber)
{
	// Destroy the msgbox!
	root.PopWindow();
    if (buttonNumber==0){
        HealAllParts();
    }

	return True;
}

