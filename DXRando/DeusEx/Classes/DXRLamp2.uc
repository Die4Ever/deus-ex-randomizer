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
        lt = Spawn(class'DynamicLight');

        lt.SetPhysics(PHYS_None);
        lt.SetCollisionSize(0.0, 0.0);

        loc = Location;
        loc.z += CollisionHeight * 1.47;
        lt.SetLocation(loc);

        lt.LightHue=44;
        lt.LightSaturation = 160;
        lt.LightBrightness = 255;
        // increasing the radius to 25 causes weird flickering on a couch in the Free Clinic, probably elsewhere
        lt.LightRadius = 20;

        lt.Mesh = None;
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

defaultproperties
{
     ItemName="Stand Lamp"
     FamiliarName="Stand Lamp"
     UnfamiliarName="Stand Lamp"
}
