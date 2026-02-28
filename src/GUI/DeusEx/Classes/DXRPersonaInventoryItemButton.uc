class DXRPersonaInventoryItemButton injects PersonaInventoryItemButton;

//Duplicated from the base class, with changed fonts
event DrawWindow(GC gc)
{
    local Inventory anItem;
    local String str;
    local DeusExWeapon weapon;
    local float strWidth, strHeight;

    if (( !bDragging ) || ( bDragging && bValidSlot ))
    {
        // Draw the background
        SetFillColor();
        gc.SetStyle(DSTY_Translucent);
        gc.SetTileColor(fillColor);
        gc.DrawPattern(1, 1, width - 2, height - 2, 0, 0, fillTexture);
    }

    if ( !bDragging )
    {
        gc.SetStyle(DSTY_Masked);
        gc.SetTileColor(colIcon);

        // Draw icon centered in button
        gc.DrawTexture(((width) / 2)  - (iconPosWidth / 2),
                    ((height) / 2) - (iconPosHeight / 2),
                    iconPosWidth, iconPosHeight,
                    0, 0,
                    icon);

        anItem = Inventory(GetClientObject());

        // If this item is an inventory item *and* it's in the object
        // belt, draw a small number in the
        // upper-right corner designating it's position in the belt

        if ( anItem.bInObjectBelt )
        {
            gc.SetFont(Font'DXRFontMenuSmall_DS'); //RANDO: Changed to better font
            gc.SetAlignments(HALIGN_Right, VALIGN_Center);
            gc.SetTextColor(colHeaderText);
            gc.GetTextExtent(0, strWidth, strHeight, anItem.beltPos);
            gc.DrawText(width - strWidth - 3, 3, strWidth, strHeight, anItem.beltPos);
        }

        // If this is an ammo or a LAM (or other thrown projectile),
        // display the number of rounds remaining
        //
        // If it's a weapon that takes ammo, then show the type of
        // ammo loaded into it

        if (anItem.IsA('DeusExAmmo') || anItem.IsA('DeusExWeapon'))
        {
            weapon = DeusExWeapon(anItem);
            str = "";

            if ((weapon != None) && weapon.bHandToHand && (weapon.AmmoType != None) && (weapon.AmmoName != class'AmmoNone'))
            {
                str = String(weapon.AmmoType.AmmoAmount);
                if (str == "1")
                    str = Sprintf(RoundLabel, str);
                else
                    str = Sprintf(RoundsLabel, str);
            }
            else if (anItem.IsA('DeusExAmmo'))
            {
                str = String(DeusExAmmo(anItem).AmmoAmount);
                if (str == "1")
                    str = Sprintf(RoundLabel, str);
                else
                    str = Sprintf(RoundsLabel, str);
            }
            else if ((weapon != None) && (!weapon.bHandToHand))
            {
                str = weapon.AmmoType.beltDescription;
            }

            if (str != "")
            {
                gc.SetFont(Font'DXRFontMenuSmall_DS'); //RANDO: Changed to better font
                gc.SetAlignments(HALIGN_Center, VALIGN_Center);
                gc.SetTextColor(colHeaderText);
                gc.GetTextExtent(0, strWidth, strHeight, str);
                gc.DrawText(0, height - strHeight, width, strHeight, str);
            }
        }

        // Check to see if we need to print "x copies"
        if (anItem.IsA('DeusExPickup') && (!anItem.IsA('NanoKeyRing')))
        {
            if (DeusExPickup(anItem).NumCopies > 1)
            {
                str = Sprintf(CountLabel, DeusExPickup(anItem).NumCopies);

                gc.SetFont(Font'DXRFontMenuSmall_DS'); //RANDO: Changed to better font
                gc.SetAlignments(HALIGN_Center, VALIGN_Center);
                gc.SetTextColor(colHeaderText);
                gc.GetTextExtent(0, strWidth, strHeight, str);
                gc.DrawText(0, height - strHeight, width, strHeight, str);
            }
        }
    }

    // Draw selection border width/height of button
    if (bSelected)
    {
        gc.SetTileColor(colSelectionBorder);
        gc.SetStyle(DSTY_Masked);
        gc.DrawBorders(0, 0, width, height, 0, 0, 0, 0, texBorders);
    }
}
