class DXRStoredLightType extends Info;

var int VersionNum; //To theoretically help with upgrades if more information is added in this class

var ELightType origLightType;


static function DXRStoredLightType Init(Actor l)
{
    local DXRStoredLightType slf;

    //Only store information for lights that have problematic light types
    //GMDX and Revision use LT_Blink in a few places, which seems basically the same as Flicker and Strobe
    if (!(l.LightType==LT_Flicker || l.LightType==LT_Strobe || l.LightType==LT_Blink)) return None;

    slf = l.Spawn(class'DXRStoredLightType',,,l.Location);

    slf.SetOwner(l);

    slf.origLightType = l.LightType;

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

    return slf;
}


function ApplyEpilepsyFix(bool enabled)
{
    local #var(prefix)ElectricityEmitter ee;

    if (Owner==None) return;

    ee = #var(prefix)ElectricityEmitter(Owner);

    if (ee!=None){
        //Handling for flickering electricity emitters, which switch between LT_Steady and LT_None randomly
        if (enabled){
            ee.bFlicker=False;
            if (ee.bIsOn){
                ee.LightType = LT_Pulse;
                //ee.LightType = LT_Steady; //Maybe flickering electricity emitters should just become steady light sources? idk
                ee.LightPeriod = 24;
                ee.SetHiddenBeam(False); //Make sure the electricity isn't hidden
            }
        } else {
            ee.LightType = LT_None;
            ee.bFlicker=True;
        }
    } else {
        //Standard light handling
        if (enabled){
            Owner.LightType = LT_Pulse; //more gentle light mode
        } else {
            Owner.LightType = origLightType;
        }
    }

}

defaultproperties
{
    VersionNum=1
    bAlwaysRelevant=True
}
