class DXRDartFlare injects DartFlare;

auto simulated state Flying
{
    //It's goofy that this is in a function called Explode despite not exploding, but oh well
    simulated function Explode(vector HitLocation, vector HitNormal)
	{
        if (Pawn(damagee)!=None){
            DamageType='FlareFlamed'; //Special damage type that only burns for a short period of time
        } else {
            DamageType='Burned'; //Default flare dart damage type
        }
        Super.Explode(HitLocation,HitNormal);
    }
}
