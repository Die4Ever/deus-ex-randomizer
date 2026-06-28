//For a rocket that fixes the reload problems with the GEP if you have
//more than one shot in the clip.  This is fixed in RocketFixTicks too,
//but this class is for an "unmodified" rocket for Zero Rando.
class GMDXRocket extends #var(prefix)Rocket;
#compileif gmdxnotae

simulated function Destroyed()
{
    class'GMDXGepGun'.static.RocketDestroyed(self);

    Super.Destroyed();
}
