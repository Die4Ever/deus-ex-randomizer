//=============================================================================
// ColorThemeMenu_Swirl
//=============================================================================

class ColorThemeMenu_Swirl extends ColorThemeMenu_Dynamic;

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
