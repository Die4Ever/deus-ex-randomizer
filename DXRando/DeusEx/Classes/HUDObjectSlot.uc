class DXRHUDObjectSlot injects HUDObjectSlot;

var String      ammoText;

event DrawWindow(GC gc)
{
    Super.DrawWindow(gc);

	// Don't draw any of this if we're dragging
	if ((item != None) && (item.Icon != None) && (!bDragging))
	{

		// Text defaults
		gc.SetAlignments(HALIGN_Center, VALIGN_Center);
		gc.EnableWordWrap(false);
		gc.SetTextColor(colObjectNum);
         
        if (ammoText!="") {
            gc.SetAlignments(HALIGN_Left, VALIGN_Center);
            gc.DrawText(slotIconX+2, itemTextPosY-8, slotFillWidth, 8, ammoText);
            gc.SetAlignments(HALIGN_Center, VALIGN_Center);
            
        }
    }
}

function bool ShouldDisplayAmmo(DeusExWeapon weapon)
{
    if (weapon.AmmoName == class'AmmoNone') {
        return False;
    }
    
    if (weapon.bHandToHand == True) {
        return False;
    }
	
    if (weapon.IsA('WeaponNanoVirusGrenade') || 
		weapon.IsA('WeaponGasGrenade') || 
		weapon.IsA('WeaponEMPGrenade') ||
		weapon.IsA('WeaponLAM'))
	{
        return False;
    }
    
    return True;
}


function UpdateItemText()
{
	local DeusExWeapon weapon;
    
    super.UpdateItemText();
    
    ammoText = "";
	if (item != None)
	{
		if (item.IsA('DeusExWeapon'))
		{
			// If this is a weapon, show the number of remaining rounds 
			weapon = DeusExWeapon(item);
            
            if (weapon.IsA('WeaponShuriken'))
            {
				if (weapon.AmmoType.AmmoAmount > 1)
					itemText = CountLabel @ weapon.AmmoType.AmmoAmount;            
            } else {
                if (ShouldDisplayAmmo(weapon))
					ammoText = string(weapon.AmmoType.AmmoAmount);

            }
        }
    }
}