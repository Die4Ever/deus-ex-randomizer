//=============================================================================
// Lamp2 except with a warm white light at the top.
// Fuck daylight bulbs.
// Localization files overwrite the ItemName,
// so really force it to not be halogen
//=============================================================================
class DXRLamp2 injects #var(prefix)Lamp2;

var DynamicLight lt;

function InitLight()
{
    local vector loc;

    if (lt == None) {
        loc = Location;
        loc.z += CollisionHeight * 1.35;

        lt = Spawn(class'DynamicLight',,, loc);
        lt.SetBase(self);

        lt.LightHue = default.LightHue;
        lt.LightSaturation = default.LightSaturation;
        lt.LightBrightness = default.LightBrightness;
        lt.LightRadius = default.LightRadius;
    }

    SetState(bOn);
}

function SetState(bool turnOn)
{
    if (turnOn) {
        bOn = true;
        lt.LightType = LT_Steady;
        bUnlit = True;
        ScaleGlow = 3.0;
    } else {
        bOn = false;
        lt.LightType = LT_None;
        bUnlit = False;
        ResetScaleGlow();
    }

    LightType = LT_NONE;
}

function Frob(Actor frobber, Inventory frobWith)
{
    Super.Frob(frobber, frobWith);
    SetState(bOn);
}

function Destroyed() { if (lt != None) lt.Destroy(); }

defaultproperties
{
    ItemName="Stand Lamp"
    FamiliarName="Stand Lamp"
    UnfamiliarName="Stand Lamp"
    LightHue=44
    LightSaturation=160
    LightBrightness=255
    // increasing the radius to ~21-25 causes weird flickering on a couch in the Free Clinic, probably elsewhere
    LightRadius=15
}
