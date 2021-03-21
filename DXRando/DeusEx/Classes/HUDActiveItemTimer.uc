//=============================================================================
// HUDActiveItemTimer
//=============================================================================

class HUDActiveItemTimer extends HUDActiveItem;

var Color colBlack;

//Not actually drawing a hotkey here, but rather a label
function DrawHotKey(GC gc)
{
    local DXRandoCrowdControlTimer timer;
    
    timer = DXRandoCrowdControlTimer(GetClientObject());
    
    if (timer == None) {
        return;
    }
    
    gc.SetAlignments(HALIGN_Left, VALIGN_Bottom);
    gc.SetFont(Font'FontTiny');
    
    // Draw Dropshadow
    gc.SetTextColor(colBlack);
    gc.DrawText(0, 22, 50, 8, timer.GetTimerLabel());

    // Draw Dropshadow
    gc.SetTextColor(colText);
    gc.DrawText(1, 21, 50, 8, timer.GetTimerLabel());
}

event DrawWindow(GC gc)
{
    Super(HUDBaseWindow).DrawWindow(gc);

    if (icon != None)
    {
        // Now draw the icon
        gc.SetStyle(iconDrawStyle);
        gc.SetTileColor(colItemIcon);
        gc.DrawTexture(9, 2, 32, 32, 0, 0, icon);
    }

    DrawHotKey(gc);
}
