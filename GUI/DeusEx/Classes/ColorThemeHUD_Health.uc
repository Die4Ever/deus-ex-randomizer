//=============================================================================
// ColorThemeHUD_Health
//=============================================================================

class ColorThemeHUD_Health extends ColorThemeHUD;

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

var DeusExPlayer player;
var float UpdateTime;

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function FindHealthColour(float health)
{
    local int i;
    local Color healthColour;

    if (health > 0 && player!=None && player.RootWindow!=None){
        healthColour = player.rootWindow.GetColorScaled(health/100.0);
    } else {
        healthColour.r=255;
        healthColour.g=0;
        healthColour.b=0;
    }

    for (i=0;i<=13;i++){
        Colors[i]=healthColour;
    }
    if (DeusExRootWindow(player.rootWindow)!=None){
        DeusExRootWindow(player.rootWindow).ChangeStyle();
    }
}

function SetUIColour()
{
    local float critHealth;
    if (player!=None){
        critHealth = MIN(player.HealthHead, player.HealthTorso);
        player.GenerateTotalHealth();

        FindHealthColour(MIN(player.Health,critHealth));
    } else {
        FindHealthColour(0);
    }
}

function Timer()
{
    SetUIColour();
}

function BeginPlay()
{
    local DeusExPlayer p;
    Super.BeginPlay();
    foreach AllActors(class'DeusExPlayer',p){player = p; }
    SetUIColour();
    SetTimer(UpdateTime,true);
}

defaultproperties
{
    themeName="Health"
    bSystemTheme=True
    bAlwaysTick=True
    UpdateTime=0.1
    Colors(0)=(R=0,G=0,B=0,A=0),
    Colors(1)=(R=0,G=0,B=0,A=0),
    Colors(2)=(R=0,G=0,B=0,A=0),
    Colors(3)=(R=0,G=0,B=0,A=0),
    Colors(4)=(R=0,G=0,B=0,A=0),
    Colors(5)=(R=0,G=0,B=0,A=0),
    Colors(6)=(R=0,G=0,B=0,A=0),
    Colors(7)=(R=0,G=0,B=0,A=0),
    Colors(8)=(R=0,G=0,B=0,A=0),
    Colors(9)=(R=0,G=0,B=0,A=0),
    Colors(10)=(R=0,G=0,B=0,A=0),
    Colors(11)=(R=0,G=0,B=0,A=0),
    Colors(12)=(R=0,G=0,B=0,A=0),
    Colors(13)=(R=0,G=0,B=0,A=0),
}
