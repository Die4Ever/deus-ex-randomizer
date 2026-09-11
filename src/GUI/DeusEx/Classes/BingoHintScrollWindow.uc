class BingoHintScrollWindow extends PersonaScrollAreaWindow;

//Use the menu theme instead of the HUD theme
event StyleChanged()
{
    local ColorTheme theme;

    theme = player.ThemeManager.GetCurrentMenuColorTheme();

    // Title colors
    colButtonFace = theme.GetColorFromName('MenuColor_ButtonFace');

    upButton.SetButtonColors(colButtonFace, colButtonFace, colButtonFace,
                                colButtonFace, colButtonFace, colButtonFace);

    downButton.SetButtonColors(colButtonFace, colButtonFace, colButtonFace,
                                colButtonFace, colButtonFace, colButtonFace);

    vScale.SetScaleColor(colButtonFace);
    vScale.SetThumbColor(colButtonFace);
}
