class DXRHUDActiveAug injects HUDActiveAug;

function DrawHotKey(GC gc)
{
    gc.SetAlignments(HALIGN_Right, VALIGN_Top);

    if (class'MenuChoice_AugHotkeys'.static.ShouldHide()) return;

    if (class'MenuChoice_AugHotkeys'.static.ShowLarge()){
        gc.SetFont(Font'DXRFontMenuSmall_DS');
        gc.SetTextColor(colText);
        gc.DrawText(15, 0, 17, 11, hotKeyString);
    } else if (class'MenuChoice_AugHotkeys'.static.ShowSmall()){
        gc.SetFont(Font'DXRFontTiny');

        // Draw Dropshadow
        gc.SetTextColor(colBlack);
        gc.DrawText(16, 1, 15, 8, hotKeyString);

        // Draw Dropshadow
        gc.SetTextColor(colText);
        gc.DrawText(17, 0, 15, 8, hotKeyString);
    }
}
