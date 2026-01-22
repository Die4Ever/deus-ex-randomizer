class DXRHUDActiveItem injects HUDActiveItem;

//Duped from HUDActiveItemBase, but adjusted coordinates
//The offset used seems to be more intended for HUDActiveAug than here
event DrawWindow(GC gc)
{
    local Texture temp;

    temp = icon;
    icon = None; //So the icon doesn't get drawn by the super function, but we get the rest
    Super.DrawWindow(gc);
    icon = temp;

    if (icon != None)
    {
        // Now draw the icon
        gc.SetStyle(iconDrawStyle);
        gc.SetTileColor(colItemIcon);
        gc.DrawTexture(1, 0, 32, 32, 0, 0, icon); //DXRando changed coordinates for items
    }

    DrawHotKey(gc);
}
