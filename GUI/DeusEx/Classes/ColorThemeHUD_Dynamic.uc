class ColorThemeHUD_Dynamic extends ColorThemeHUD abstract;

var DeusExPlayer player;
var travel ColorThemeManager ThemeManager;
var float UpdateTime;

function BeginPlay()
{
    Super.BeginPlay();
    foreach AllActors(class'DeusExPlayer', player) {
        ThemeManager = player.ThemeManager;
        break;
    }
    UpdateColours();
    SetTimer(UpdateTime, true);
}

function Timer()
{
    if(ThemeManager != None && ThemeManager.currentHUDTheme == self) {
        UpdateColours();
    }
}

function UpdateColours();

defaultproperties
{
    themeName="Dynamic"
    bSystemTheme=True
    bAlwaysTick=True
    UpdateTime=1
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
