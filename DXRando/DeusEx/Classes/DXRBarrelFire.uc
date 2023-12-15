class DXRBarrelFire injects #var(prefix)BarrelFire;

var float lastIgniteTime;
var ParticleGenerator fireGen;

function DamageOther(Actor Other)
{
  //This function does nothing now
}

function DamageOtherReal(Actor Other,bool supporting)
{
	if ((Other != None) && !Other.IsA('ScriptedPawn'))
	{
        //Only make it possible to ignite periodically, but this takes precedence over regular damage
        if (supporting && Level.TimeSeconds - lastIgniteTime >= 5.0)
        {
            Other.TakeDamage(5, None, Location, vect(0,0,0), 'Flamed');
            lastIgniteTime = Level.TimeSeconds;
            lastDamageTime = Level.TimeSeconds;
        }

		// only take damage every second
		if (Level.TimeSeconds - lastDamageTime >= 1.0)
		{
			Other.TakeDamage(5, None, Location, vect(0,0,0), 'Burned');
			lastDamageTime = Level.TimeSeconds;
		}
	}
}

singular function SupportActor(Actor Other)
{
	DamageOtherReal(Other,True);
	Super(Containers).SupportActor(Other);
}

singular function Bump(Actor Other)
{
	DamageOtherReal(Other,False);
	Super(Containers).Bump(Other);
}

function Tick(float delta)
{
    if( (Pawn(Base) != None) && (Pawn(Base).CarriedDecoration == self) ) {
        DamageOtherReal(Base, False);
    }

    Super.Tick(delta);
}

function Destroyed()
{
	local Rotator rot;
	local Vector loc;
    local DXRFireballShrinking fireball;
	local TrashPaper trash;
    local int i;
    local float MaxDrawScale;
    local float radians, radDelta, radius;

    log("!FastTrace(loc) = " $ !FastTrace(loc));

    loc = vect(0,0,0);
    loc.Z -= CollisionHeight + 8.0;
    loc += Location;

    if (!FastTrace(loc)) {
        for (i=0; i<2; i++)
        {
            if (FRand() < 0.75)
            {
                loc = Location;
                loc.X += (CollisionRadius / 2) - FRand() * CollisionRadius;
                loc.Y += (CollisionRadius / 2) - FRand() * CollisionRadius;
                loc.Z += (CollisionHeight / 2) - FRand() * CollisionHeight;
                trash = Spawn(class'TrashPaper',,, loc);
                if (trash != None)
                {
                    trash.SetPhysics(PHYS_Rolling);
                    trash.rot = RotRand(True);
                    trash.rot.Yaw = 0;
                    trash.dir = VRand() * 20 + vect(20,20,0);
                    trash.dir.Z = 0;
                }
            }
        }
    }

    MaxDrawScale = 0.00085 * CollisionRadius;
    radius = CollisionRadius * 0.9;
    radDelta = 6.28318530718 / 5;
    for (radians = 0; radians <= 6.28318530718; radians += radDelta) {
        loc = Location;
        loc.X += Cos(radians) * radius;
        loc.Y += Sin(radians) * radius;
        loc.Z += 0.95 * CollisionHeight;

        fireball = Spawn(class'DXRFireballShrinking',,, loc);
        if (fireball != None) {
            fireball.speed = 0;
            fireball.MaxSpeed = 0;
            fireball.MaxDrawScale = MaxDrawScale;
        }
    }

    Super.Destroyed();
}

// same as Barrel1
defaultproperties
{
    Mass=80
    Buoyancy=90
    bInvincible=False
}
