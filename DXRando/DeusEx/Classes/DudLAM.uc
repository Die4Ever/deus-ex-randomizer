class DudLAM extends #var(prefix)LAM;


function Frob(Actor Frobber, Inventory frobWith)
{
    //Intentionally do nothing
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    local ParticleGenerator gen;

    if (bDisabled) return;

    bDisabled=True;

    PlaySound(sound'EMPZap', SLOT_None,,, 1280);

    ItemName="A Dud!";

    gen = Spawn(class'ParticleGenerator', Self,, Location, rot(16384,0,0));
        if (gen != None)
        {
            gen.checkTime = 0.25;
            gen.LifeSpan = 2;
            gen.particleDrawScale = 0.3;
            gen.bRandomEject = True;
            gen.ejectSpeed = 10.0;
            gen.bGravity = False;
            gen.bParticlesUnlit = True;
            gen.frequency = 0.5;
            gen.riseRate = 10.0;
            gen.spawnSound = Sound'Spark2';
            gen.particleTexture = Texture'Effects.Smoke.SmokePuff1';
            gen.SetBase(Self);
        }
}

auto simulated state Flying
{
    simulated function Explode(vector HitLocation, vector HitNormal)
    {
        Global.Explode(HitLocation,HitNormal);
    }
}
