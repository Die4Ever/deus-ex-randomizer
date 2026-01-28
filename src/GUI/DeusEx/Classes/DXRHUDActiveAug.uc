class DXRHUDActiveAug injects HUDActiveAug;

var PersonaLevelIconWindow winLevels;

function DrawHotKey(GC gc)
{
    local Augmentation aug;
    local int showLevels;

    aug = Augmentation(GetClientObject());
    if(aug != None) {
        gc.SetFont(Font'DXRFontMenuSmall_DS');
        gc.SetTextColor(colText);

        showLevels = class'MenuChoice_AugLevels'.default.value;
        if(showLevels != 1 && winLevels != None) {
            winLevels.Destroy();
            winLevels = None;
        }
        switch(showLevels) {
        case 1: // dots
            if(winLevels == None) {
                winLevels = PersonaLevelIconWindow(NewChild(Class'PersonaLevelIconWindow'));
                winLevels.SetPos(4, 29);
                winLevels.SetSelected(True);
            }
            winLevels.SetLevel(aug.CurrentLevel);
            break;

        case 2: // left
            gc.SetAlignments(HALIGN_Left, VALIGN_Top);
            gc.DrawText(2, 24, 17, 11, aug.CurrentLevel);
            break;

        case 3: // right
            gc.SetAlignments(HALIGN_Right, VALIGN_Top);
            gc.DrawText(15, 25, 17, 11, aug.CurrentLevel);
            break;
        }
    }

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
