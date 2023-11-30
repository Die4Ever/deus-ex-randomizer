//=============================================================================
// ColorThemeMenu_Health
//=============================================================================

class ColorThemeMenu_Health extends ColorThemeMenu;

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
}
