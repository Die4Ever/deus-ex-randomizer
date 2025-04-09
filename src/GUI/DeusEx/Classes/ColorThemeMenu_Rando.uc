//=============================================================================
// ColorThemeMenu_Rando
//=============================================================================

class ColorThemeMenu_Rando extends ColorThemeMenu_Dynamic;

/*
   Colors!

	colorNames(0)=MenuColor_Background
	colorNames(1)=MenuColor_TitleBackground
	colorNames(2)=MenuColor_TitleText
	colorNames(3)=MenuColor_ButtonFace
	colorNames(4)=MenuColor_ButtonTextNormal
	colorNames(5)=MenuColor_ButtonTextFocus
	colorNames(6)=MenuColor_ButtonTextDisabled
	colorNames(7)=MenuColor_HelpText
	colorNames(8)=MenuColor_ListText
	colorNames(9)=MenuColor_ListTextHighlight
	colorNames(10)=MenuColor_ListHighlight
	colorNames(11)=MenuColor_ListFocus
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
    for (i=0;i<=12;i++){
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
