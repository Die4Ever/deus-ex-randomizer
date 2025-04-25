class DXRPersonaLevelIconWindow injects PersonaLevelIconWindow;

event DrawWindow(GC gc)
{
    local int levelCount,maxLevel;
    local Window parentWin;
    local Augmentation clientAug;

    maxLevel=3;
    parentWin=GetParent();
    if (parentWin!=None){
        clientAug = Augmentation(parentWin.GetClientObject());
        if(clientAug!=None && clientAug.AugmentationLocation!=LOC_Default){
            maxLevel = clientAug.MaxLevel;
        }
    }

    for(levelCount=0; levelCount<=3; levelCount++)
    {
        if (levelCount<=currentLevel){
            gc.SetTileColor(colText);
            gc.SetStyle(DSTY_Masked);
            gc.DrawTexture(levelCount * (iconSizeX + 1), 0, iconSizeX, iconSizeY,
                0, 0, texLevel);
        } else if (levelCount>maxLevel){
            gc.SetTileColor(colBackground);
            gc.SetStyle(backgroundDrawStyle);
            gc.DrawTexture(levelCount * (iconSizeX + 1), 0, iconSizeX, iconSizeY,
                0, 0, Texture'AugSlotCover');
        }
    }
}

event StyleChanged()
{
    local ColorTheme theme;

    Super(PersonaBaseWindow).StyleChanged();

    theme = player.ThemeManager.GetCurrentHUDColorTheme();

    if (bSelected)
        colText = theme.GetColorFromName('HUDColor_ButtonTextFocus');
    else
        colText = theme.GetColorFromName('HUDColor_ButtonTextNormal');
}
