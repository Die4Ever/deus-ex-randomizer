//=============================================================================
// ColorThemeHUD_Swirl
//=============================================================================

class ColorThemeHUD_Swirl extends ColorThemeHUD_Dynamic;

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

var int rgbAngle[15]; //One per theme segment

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function RandomAllAngles()
{
    local int i;
    for (i=0;i<15;i++){
        rgbAngle[i]=Rand(360);
    }
}
function int getPositiveAngleDiff(int a, int b)
{
    if (a<b){
        return a+360-b;
    } else {
        return a-b;
    }
}

function Color GetColorFromAngle(int angle)
{
    local Color c;
    local int components[3];
    local int startAngle,i;
    local float diffFromStart;
    for (i=1;i<=3;i++){
        startAngle = ((i+1)*120)%360;
        diffFromStart = getPositiveAngleDiff(angle, startAngle);
        if (diffFromStart < 60){
            components[i-1] = int(diffFromStart/60*255);
        } else if (diffFromStart <= 180) {
            components[i-1] = 255;
        } else if (diffFromStart < 240) {
            components[i-1] = int((240-diffFromStart)/60*255);
        } else {
            components[i-1] = 0;
        }

    }
    c.R=components[0];
    c.G=components[1];
    c.B=components[2];
    return c;
}

function UpdateColours()
{
    local int i;
    for (i=0;i<=13;i++){
        rgbAngle[i]=(rgbAngle[i]+1)%360;
        Colors[i]=GetColorFromAngle(rgbAngle[i]);
    }
    if (DeusExRootWindow(player.rootWindow)!=None){
        DeusExRootWindow(player.rootWindow).ChangeStyle();
    }
}

defaultproperties
{
    themeName="Swirl"
    UpdateTime=0.1
}
