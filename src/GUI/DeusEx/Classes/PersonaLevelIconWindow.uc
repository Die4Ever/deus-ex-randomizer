class DXRPersonaLevelIconWindow injects PersonaLevelIconWindow;

var bool HideMaxLevelCovers;
var bool ShowLevelFive;

event InitWindow()
{
    Super.InitWindow();

    SetSize( ((iconSizeX + 1) * 5) - 1, 5); //Enough space for five icons
}

event DrawWindow(GC gc)
{
    local int levelCount,maxLevel,actLevel,boostedLevel;
    local Window parentWin;
    local Augmentation clientAug;

    maxLevel=3;
    actLevel=currentLevel;
    boostedLevel = -1;

    parentWin=GetParent();
    if (parentWin!=None){
        clientAug = Augmentation(parentWin.GetClientObject());
        if(clientAug!=None && clientAug.AugmentationLocation!=LOC_Default){
            maxLevel = clientAug.MaxLevel;

            //Don't show the boosted level, show the actual level
            if (clientAug.bBoosted){
                actLevel = actLevel-1;
                boostedLevel = currentLevel;
            }
        }
    }

    for(levelCount=0; levelCount<=4; levelCount++)
    {
        if (!ShowLevelFive && levelCount==4) continue;

        if (levelCount<=actLevel){
            gc.SetTileColor(colText);
            gc.SetStyle(DSTY_Masked);
            gc.DrawTexture(levelCount * (iconSizeX + 1), 0, iconSizeX, iconSizeY,
                0, 0, texLevel);
        } else if (levelCount>maxLevel && !HideMaxLevelCovers && levelCount!=4){ //Don't show a cover for level 5
            gc.SetTileColor(colBackground);
            gc.SetStyle(backgroundDrawStyle);
            gc.DrawTexture(levelCount * (iconSizeX + 1), 0, iconSizeX, iconSizeY,
                0, 0, Texture'AugSlotCover');
        } else if (boostedLevel>actLevel && levelCount<=boostedLevel){
            gc.SetTileColor(colText);
            gc.SetStyle(DSTY_Masked);
            gc.DrawTexture(levelCount * (iconSizeX + 1), 0, iconSizeX, iconSizeY,
                0, 0, Texture'AugSlotBoosted');

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
