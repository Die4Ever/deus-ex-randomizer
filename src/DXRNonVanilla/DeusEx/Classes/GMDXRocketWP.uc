//For a rocket that fixes the reload problems with the GEP if you have
//more than one shot in the clip.
class GMDXRocketWP extends #var(prefix)RocketWP;
#compileif gmdxnotae

simulated function Destroyed()
{
    class'GMDXGepGun'.static.RocketDestroyed(self);

    Super.Destroyed();
}
