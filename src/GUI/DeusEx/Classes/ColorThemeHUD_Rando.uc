//=============================================================================
// ColorThemeHUD_Rando
//=============================================================================

class ColorThemeHUD_Rando extends ColorThemeHUD_Dynamic;

/*
   Colors!
	colors(0) = HUDColor_Background
	colors(1) = HUDColor_Borders
	colors(2) = HUDColor_TitleText
	colors(3) = HUDColor_ButtonFace
	colors(4) = HUDColor_ButtonTextNormal
	colors(5) = HUDColor_ButtonTextFocus
	colors(6) = HUDColor_ButtonTextDisabled
	colors(7) = HUDColor_HeaderText
	colors(8) = HUDColor_NormalText
	colors(9) = HUDColor_ListText
	colors(10) = HUDColor_ListTextHighlight
	colors(11) = HUDColor_ListHighlight
	colors(12) = HUDColor_ListFocus
	colors(13) = HUDColor_Cursor
*/

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function Color RandomColor()
{
    local Color newColor;

    newColor.R = Rand(256);
    newColor.G = Rand(256);
    newColor.B = Rand(256);

    return newColor;
}

function UpdateColours()
{
    local int i;
    for (i=0;i<=13;i++){
        Colors[i]=RandomColor();
    }
    if (DeusExRootWindow(player.rootWindow)!=None){
        DeusExRootWindow(player.rootWindow).ChangeStyle();
    }
}

defaultproperties
{
    themeName="Rando"
    UpdateTime=0.5
}
