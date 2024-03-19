//=============================================================================
// ColorThemeMenu_Health
//=============================================================================

class ColorThemeMenu_Health extends ColorThemeMenu_Dynamic;

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

static function Color GetHealthColor(DeusExPlayer player)
{
    local float health;
    local Color healthColour;

    if(player.Health > 0)
        player.GenerateTotalHealth();

    health = player.Health;
    health = MIN(health, player.HealthHead);
    health = MIN(health, player.HealthTorso);
    health = MAX(health, 0);

    if (health > 0 && player!=None && player.RootWindow!=None){
        healthColour = player.rootWindow.GetColorScaled(health/100.0);
    } else {
        healthColour.r=255;
        healthColour.g=0;
        healthColour.b=0;
    }

    return healthColour;
}

function UpdateColours()
{
    local int i;
    local Color healthColour;

    healthColour = GetHealthColor(player);

    for (i=0;i<=13;i++){
        Colors[i]=healthColour;
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
