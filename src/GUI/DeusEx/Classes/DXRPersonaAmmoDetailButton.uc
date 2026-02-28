class DXRPersonaAmmoDetailButton injects PersonaAmmoDetailButton;

//Duplicated from vanilla, but swapped fonts to better versions
event DrawWindow(GC gc)
{
    local String str, descStr;
    local float strWidth, strHeight, strRoundsHeight;

    // Draw background
    if (bLoaded)
    {
        // Draw the background
        gc.SetStyle(DSTY_Translucent);
        gc.SetTileColor(colFillSelected);
        gc.DrawPattern(1, 1, width - 2, height - 2, 0, 0, Texture'Solid');
    }

    // Draw icon
    if (icon != None)
    {
        // Draw the icon
        if (bIconTranslucent)
            gc.SetStyle(DSTY_Translucent);
        else
            gc.SetStyle(DSTY_Masked);

        if (bHasIt)
            gc.SetTileColor(colIcon);
        else
            gc.SetTileColor(colSelectionBorderHalf);

        gc.DrawTexture(((borderWidth) / 2)  - (iconPosWidth / 2),
                    ((borderHeight) / 2) - (iconPosHeight / 2),
                    iconPosWidth, iconPosHeight,
                    0, 0,
                    icon);
    }

    // Draw border
    if (!bSelected)
        gc.SetTileColor(colSelectionBorderHalf);
    else
        gc.SetTileColor(colSelectionBorder);

    gc.SetStyle(DSTY_Masked);
    gc.DrawBorders(0, 0, borderWidth, borderHeight, 0, 0, 0, 0, texBorders);

    // Draw the item name
    descStr = ammo.Default.beltDescription;

    gc.SetFont(Font'DXRFontTiny'); //RANDO: Updated font to better one
    gc.SetAlignments(HALIGN_Center, VALIGN_Top);
    gc.GetTextExtent(0, strWidth, strHeight, descStr);

    if ((bHasIt) && (rounds > 0))
    {
        str = String(rounds);

        if (str == "1")
            str = Sprintf(RoundLabel, str);
        else
            str = Sprintf(RoundsLabel, str);
    }

    if (bHasIt)
        gc.SetTextColor(colHeaderText);
    else
        gc.SetTextColor(colSelectionBorderHalf);

    if (str != "")
    {
        gc.GetTextExtent(0, strWidth, strRoundsHeight, str);
        gc.DrawText(0, height - strHeight - strRoundsHeight + 2, width, strHeight, descStr);
        gc.DrawText(0, height - strRoundsHeight, width, strHeight, str);
    }
    else
    {
        gc.DrawText(0, height - strHeight - strRoundsHeight, width, strHeight, descStr);
    }
}
