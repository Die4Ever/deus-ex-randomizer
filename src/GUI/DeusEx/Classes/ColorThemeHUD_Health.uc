//=============================================================================
// ColorThemeHUD_Health
//=============================================================================

class ColorThemeHUD_Health extends ColorThemeHUD_Dynamic;

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

function UpdateColours()
{
    local int i;
    local Color healthColour;

    healthColour = class'ColorThemeMenu_Health'.static.GetHealthColor(player);

    for (i=0;i<=13;i++){
        switch(i){
            case 6:  //HUDColor_ButtonTextDisabled
            case 11: //HUDColor_ListHighlight
                //Dark Gray for disabled buttons and list highlights, so they stand out
                Colors[i].R=20;
                Colors[i].G=20;
                Colors[i].B=20;
                break;
            default:
                Colors[i]=healthColour;
                break;
        }
    }
    if (DeusExRootWindow(player.rootWindow)!=None){
        DeusExRootWindow(player.rootWindow).ChangeStyle();
    }
}

defaultproperties
{
    themeName="Health"
    UpdateTime=0.1
}
