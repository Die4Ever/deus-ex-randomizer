class DXRHUDActiveAug injects HUDActiveAug;

var #var(prefix)PersonaLevelIconWindow winLevels;

event DestroyWindow()
{
    SetClientObject(None);
    Super.DestroyWindow();
}

function DrawHotKey(GC gc)
{
    local Augmentation aug;
    local int showLevels,augLevel;
    local string boostText;

    aug = Augmentation(GetClientObject());
    if(aug != None && aug.bDeleteMe) {
        SetClientObject(None);
        aug = None;
    }
    showLevels = class'MenuChoice_AugLevels'.default.value;
    if(winLevels != None && (aug == None || showLevels != 1)) {
        winLevels.Destroy();
        winLevels = None;
    }
    if(aug != None) {
        gc.SetFont(Font'DXRFontMenuSmall_DS');
        gc.SetTextColor(colText);

        augLevel = aug.CurrentLevel;
        if (aug.bBoosted){
            //Aug level has been boosted by synthetic heart, put it back for the purposes of this menu
            augLevel = augLevel - 1;
            boostText = "+";
        }

        switch(showLevels) {
        case 1: // dots
            if(winLevels == None) {
                winLevels = #var(prefix)PersonaLevelIconWindow(NewChild(Class'#var(prefix)PersonaLevelIconWindow'));
                winLevels.SetPos(4, 29);
                winLevels.SetSelected(True);
                winLevels.HideMaxLevelCovers=true;
                winLevels.ShowLevelFive=true;
            }
            winLevels.SetLevel(aug.CurrentLevel); //The boostedness will be handled by the DXRPersonaLevelIconWindow
            break;

        case 2: // left
            gc.SetAlignments(HALIGN_Left, VALIGN_Top);
            gc.DrawText(2, 24, 17, 11, (augLevel+1)$boostText);
            break;

        case 3: // right
            gc.SetAlignments(HALIGN_Right, VALIGN_Top);
            gc.DrawText(15, 25, 17, 11, (augLevel+1)$boostText);
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
