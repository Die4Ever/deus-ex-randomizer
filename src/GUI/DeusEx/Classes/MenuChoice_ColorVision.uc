//=============================================================================
// MenuChoice_ColorVision
//
// This class should attempt to contain as many colour selections as possible,
// so that we can adjust things based on what you are able to actually see...
//=============================================================================

class MenuChoice_ColorVision extends DXRMenuUIChoiceInt;

const VIS_NORMAL   = 0;
const VIS_REDGREEN = 1;

static function Color GetHintTextColor()
{
    local Color c;

    switch(Default.Value){
        case VIS_REDGREEN:
            c = CreateColor(0,186,210);
            break;
        case VIS_NORMAL:
        default:
            c = CreateColor(255,0,0);
            break;
    }

    return c;
}

//Datacubes/Keys normally glow blue
static function int GetDatacubeKeyHue()
{
    local int hue;

    switch(Default.Value){
        case VIS_REDGREEN:
            hue = 155;
            break;
        case VIS_NORMAL:
        default:
            hue = 155;
            break;
    }

    return hue;
}

//#region Quick Augs/Skills

//Normally green
static function Color GetUpgradableColor()
{
    local Color c;

    switch(Default.Value){
        case VIS_REDGREEN:
            c = CreateColor(40,204,80,255);
            break;
        case VIS_NORMAL:
        default:
            c = CreateColor(40,204,80,255);
            break;
    }

    return c;
}

//Normally red
static function Color GetUnupgradableColor()
{
    local Color c;

    switch(Default.Value){
        case VIS_REDGREEN:
            c = CreateColor(220,90,80,255);
            break;
        case VIS_NORMAL:
        default:
            c = CreateColor(220,90,80,255);
            break;
    }

    return c;
}

//Normally goldy yellow
static function Color GetUpgradeMaxColor()
{
    local Color c;

    switch(Default.Value){
        case VIS_REDGREEN:
            c = CreateColor(216,175,31,255);
            break;
        case VIS_NORMAL:
        default:
            c = CreateColor(216,175,31,255);
            break;
    }

    return c;
}

//#endregion

//#region Bot Glow

//Ready is normally Green
static function int GetReadyHue()
{
    local int hue;

    switch(Default.Value){
        case VIS_REDGREEN:
            hue = 89;
            break;
        case VIS_NORMAL:
        default:
            hue = 89;
            break;
    }

    return hue;
}

//Not Ready is normally Red
static function int GetNotReadyHue()
{
    local int hue;

    switch(Default.Value){
        case VIS_REDGREEN:
            hue = 255;
            break;
        case VIS_NORMAL:
        default:
            hue = 255;
            break;
    }

    return hue;
}
//#endregion


//#region Target Colours

//Friendly is normally green
static function Color GetFriendlyColor()
{
    local Color c;

    switch(Default.Value){
        case VIS_REDGREEN:
            c = CreateColor(0,255,0);
            break;
        case VIS_NORMAL:
        default:
            c = CreateColor(0,255,0);
            break;
    }

    return c;
}

//Hostile is normally red
static function Color GetHostileColor()
{
    local Color c;

    switch(Default.Value){
        case VIS_REDGREEN:
            c = CreateColor(255,0,0);
            break;
        case VIS_NORMAL:
        default:
            c = CreateColor(255,0,0);
            break;
    }

    return c;
}

//Neutral is normally white
static function Color GetNeutralColor()
{
    local Color c;

    switch(Default.Value){
        case VIS_REDGREEN:
            c = CreateColor(255,255,255);
            break;
        case VIS_NORMAL:
        default:
            c = CreateColor(255,255,255);
            break;
    }

    return c;
}
//#endregion

//#region Aim Laser

//Friendly laser is normally green
static function Texture GetFriendlyLaserColor()
{

    switch(Default.Value){
        case VIS_REDGREEN:
            return Texture'Extension.SolidGreen';
            break;
        case VIS_NORMAL:
            return Texture'Extension.SolidGreen';
            break;
    }

    return Texture'Extension.SolidGreen';
}

//Hostile is normally red
static function Texture GetHostileLaserColor()
{
    local Color c;

    switch(Default.Value){
        case VIS_REDGREEN:
            return Texture'Extension.SolidRed';
            break;
        case VIS_NORMAL:
            return Texture'Extension.SolidRed';
            break;
    }

    return Texture'Extension.SolidRed';
}

//Neutral (aiming at an object or neutral person) is normally yellow
static function Texture GetNeutralLaserColor()
{
    local Color c;

    switch(Default.Value){
        case VIS_REDGREEN:
            return Texture'Extension.SolidYellow';
            break;
        case VIS_NORMAL:
            return Texture'Extension.SolidYellow';
            break;
    }

    return Texture'Extension.SolidYellow';
}

//Nothing (not aiming at an Actor) is normally white
static function Texture GetNothingLaserColor()
{
    local Color c;

    switch(Default.Value){
        case VIS_REDGREEN:
            return Texture'Extension.Solid';
            break;
        case VIS_NORMAL:
            return Texture'Extension.Solid';
            break;
    }

    return Texture'Extension.Solid';
}

//Aiming with grenade at a wall (in range) is normally light blue
static function Texture GetGrenadePlantLaserColor()
{
    local Color c;

    switch(Default.Value){
        case VIS_REDGREEN:
            return Texture'Extension.VisionBlue';
            break;
        case VIS_NORMAL:
            return Texture'Extension.VisionBlue';
            break;
    }

    return Texture'Extension.VisionBlue';
}

//#endregion

//#region Scaled Colors

//Normal colour scaling is from green to yellow to red
static function Color GetColorScaledVanilla(float percent)
{
    local Color colHigh,colMed,colLow;

    colHigh = CreateColor(0,255,0);
    //colHigh = CreateColor(0,160,0);
    colMed  = CreateColor(255,255,0);
    colLow  = CreateColor(255,0,0);

    return GetColorScaledBase(colHigh,colMed,colLow,percent);
}

//Red-Green colour blindness now scales from ? to ? to ?
static function Color GetColorScaledRedGreen(float percent)
{
    local Color colHigh,colMed,colLow;

//Light Blue -> Yellow -> Red
    //colHigh = CreateColor(0,255,200);
    //colMed  = CreateColor(255,255,0);
    //colLow  = CreateColor(255,0,0);

//White -> Gray -> dark gray //Hard to distinguish low end
    //colHigh = CreateColor(255,255,255);
    //colMed  = CreateColor(112,112,112);
    //colLow  = CreateColor(30,30,30);

//Yellow -> Rose -> Dark Blue (Viridis)
    //colHigh = CreateColor(253,231,37);
    //colMed  = CreateColor(33,145,140);
    //colLow  = CreateColor(68,1,84);

//Yellow -> Rose -> Dark Blue (Plasma)
    colHigh = CreateColor(240,249,33);
    colMed  = CreateColor(204,71,120);
    colLow  = CreateColor(13,8,135);


    return GetColorScaledBase(colHigh,colMed,colLow,percent);
}

//Baseline logic for scaling between three colour points in standard health ranges
static function Color GetColorScaledBase(color colHigh, color colMed, color colLow, float percent)
{
    local float mult;
    local Color col;

    if (percent > 0.80)
    {
        col = colHigh;
    }
    else if (percent > 0.40)
    {
        mult = (percent-0.40)/(0.80-0.40);
        col = BlendColors(colMed,colHigh,mult);
    }
    else if (percent > 0.10)
    {
        mult = (percent-0.10)/(0.40-0.10);
        col = BlendColors(colLow,colMed,mult);
    }
    else if (percent > 0)
    {
        col = colLow;
    }
    else
    {
        col = CreateColor(0,0,0);
    }

    return col;
}

//For easy debugging
static function String ColorString(Color col)
{
    return "(R="$col.R$",G="$col.G$",B="$col.B$",A="$col.A$")";
}

//Populate a Color structure in a single line
static function Color CreateColor(byte R, byte G, byte B, optional byte A)
{
    local Color c;

    c.R = R;
    c.G = G;
    c.B = B;
    c.A = A;

    return c;
}

//When percent==0.0 lowCol,   percent==1.0 highCol
//blend between as the percent shifts
//AKA Linear Colour Interpolation
static function Color BlendColors(Color lowCol, Color highCol, float percent)
{
    local Color cOut;
    local int CDiffR,CDiffG,CDiffB,CDiffA;

    CDiffR = int(highCol.R) - int(lowCol.R);
    CDiffG = int(highCol.G) - int(lowCol.G);
    CDiffB = int(highCol.B) - int(lowCol.B);
    CDiffA = int(highCol.A) - int(lowCol.A);

    //log("Blend "$ColorString(lowCol)$" to "$ColorString(highCol)$" : "$(percent*100.0)$"%");

    cOut.R = lowCol.R + (CDiffR * percent);
    cOut.G = lowCol.G + (CDiffG * percent);
    cOut.B = lowCol.B + (CDiffB * percent);
    cOut.A = lowCol.A + (CDiffA * percent);

    //log("Blended colour to "$ColorString(cOut));

    return cOut;
}

static function Color GetVisionColorScaled(float percent)
{
    switch(Default.Value){
        case VIS_REDGREEN:  //Red-Green
            return GetColorScaledRedGreen(percent);
            break;
        case VIS_NORMAL: //Normal
            return GetColorScaledVanilla(percent);
            break;
    }

    return GetColorScaledVanilla(percent);
}
//#endregion

defaultproperties
{
    value=0   //VIS_NORMAL
    defaultvalue=0  //VIS_NORMAL
    HelpText="Select the appropriate setting for your vision to try to compensate for vision deficiency|n(Work in Progress - get in touch to help us help you!)"
    actionText="Color Vision"
    enumText(0)="Normal"  //VIS_NORMAL
    enumText(1)="Red-Green"  //VIS_REDGREEN  Deuteranomaly/Deuteranopia and Protanomaly/Protanopia
    //enumText(2)="Blue-Yellow"  //Tritanomaly/Tritanopia
    //enumText(3)="Monochromacy"  //Complete/Incomplete Achromatopsia
}
