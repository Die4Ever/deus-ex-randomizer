//=============================================================================
// Lamp2 except Warm White.  Fuck daylight bulbs.
// Localization files overwrite the ItemName,
// so really force it to not be halogen
//=============================================================================
class DXRLamp2 injects #var(prefix)Lamp2;

defaultproperties
{
     ItemName="Stand Lamp"
     FamiliarName="Stand Lamp"
     UnfamiliarName="Stand Lamp"
     LightHue=44
     LightSaturation=160
     // increasing the radius to 25 causes weird flickering on a couch in the Free Clinic, probably elsewhere
     LightRadius=20
}
