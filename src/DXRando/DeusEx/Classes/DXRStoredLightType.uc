class DXRStoredLightType extends Info;

const LATEST_VERSION_NUMBER = 2; //Update this when adding new versions

var int VersionNum; //To theoretically help with upgrades if more information is added in this class

var ELightType origLightType;
var Byte       origLightPeriod;


static function DXRStoredLightType Init(Actor l)
{
    local DXRStoredLightType slf;

    //Only store information for lights that have problematic light types
    //GMDX and Revision use LT_Blink in a few places, which seems basically the same as Flicker and Strobe
    if (!(l.LightType==LT_Flicker || l.LightType==LT_Strobe || l.LightType==LT_Blink)) return None;

    slf = l.Spawn(class'DXRStoredLightType',,,l.Location);

    slf.SetOwner(l);

    slf.origLightType = l.LightType;
    slf.origLightPeriod = l.LightPeriod;

    slf.VersionNum = LATEST_VERSION_NUMBER;

    return slf;
}

static function DXRStoredLightType InitElecEmitter(#var(prefix)ElectricityEmitter ee)
{
    local DXRStoredLightType slf;

    //Electricity emitters switch between LT_Steady and LT_None at random, so need to be handled a bit differently
    //We'll still use the presence of a DXRStoredLightType to track the ones that need to be tweaked

    if (!(ee.bEmitLight==True && ee.bFlicker==True)) return None;

    slf = ee.Spawn(class'DXRStoredLightType',,,ee.Location);

    slf.SetOwner(ee);

    slf.origLightType = LT_Flicker; //Not true, just for the vibe

    //24 +/- 6, so the lights aren't all synchronized (eg. Vandenberg Computer)
    slf.origLightPeriod = 18 + Rand(13); //Randomly determine once, so it is consistent if you toggle

    slf.VersionNum = LATEST_VERSION_NUMBER;

    return slf;
}

//Timer for enabling and disabling the lighting on electricity emitters
function Timer()
{
    local #var(prefix)ElectricityEmitter ee;

    ee = #var(prefix)ElectricityEmitter(Owner);

    if (ee==None) return;

    if (ee.bIsOn){
        ee.LightType = LT_Pulse;
        ee.LightPeriod = origLightPeriod;
    } else {
        ee.LightType = LT_None;
    }
}


function ApplyEpilepsyFix(bool enabled)
{
    local #var(prefix)ElectricityEmitter ee;

    if (Owner==None) return;

    ee = #var(prefix)ElectricityEmitter(Owner);

    if (ee!=None){
        //Handling for flickering electricity emitters, which switch between LT_Steady and LT_None randomly
        if (enabled){
            ee.bEmitLight=False;
            ee.LightType = LT_Pulse;
            SetTimer(0.1,True); //Timer will manage the lighting
        } else {
            ee.LightType = LT_None;
            ee.bEmitLight=True;
            SetTimer(0.0,False); //Disable the timer again

        }
    } else {
        //Standard light handling
        if (enabled){
            Owner.LightType = LT_Pulse; //more gentle light mode
            Owner.LightPeriod = origLightPeriod;
            if (origLightPeriod < 16){
                Owner.LightPeriod = Owner.LightPeriod + 12; //so it isn't super fast still
            }
        } else {
            Owner.LightType = origLightType;
            Owner.LightPeriod = origLightPeriod;
        }
    }
}

function Upgrade()
{
    local bool upgraded;

    if (VersionNum==LATEST_VERSION_NUMBER) return; //Fast exit

    if (VersionNum < 2){
        //Version 2 started tracking light period
        if (#var(prefix)ElectricityEmitter(Owner)!=None){
            origLightPeriod = 18 + Rand(13);
        } else {
            origLightPeriod = Owner.LightPeriod;
        }
        upgraded=true;
    }

    //Add further version upgrades here

    if (upgraded){
        VersionNum = LATEST_VERSION_NUMBER;
    }
}

defaultproperties
{
    VersionNum=1 //I hate this.  The default means it isn't saved, so don't touch this.  Explicitly set it in the Init with LATEST_VERSION_NUMBER
    bAlwaysRelevant=True
}
