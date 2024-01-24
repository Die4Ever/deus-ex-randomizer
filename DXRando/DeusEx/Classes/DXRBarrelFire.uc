class DXRBarrelFire injects #var(prefix)BarrelFire;

var float lastIgniteTime;

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
    local int i;
	local Vector loc;
	local TrashPaper trash;
	local Fire fire;
    local bool fireHasSpawned;

	// trace down to see if we are sitting on the ground
	loc = vect(0,0,0);
	loc.Z -= CollisionHeight + 8.0;
	loc += Location;

	// only generate trash if we are on the ground
	if (!FastTrace(loc))
	{
        fireHasSpawned = False;

		// maybe spawn some paper
		for (i=0; i<3; i++)
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

                    // maybe set it on fire
                    if (FRand() < 0.5)
                    {
                        // trash has no collision and its collisionHeight seems to have no correspondence to its actual size
                        // this code is based on collisionHeight only for potential scaling purposes
                        loc.Z += 0.8 * trash.Collisionheight;

                        fire = Spawn(class'SmokelessFire', trash,, loc);
                        if (fire != None)
                        {
                            fire.DrawScale = 0.5*FRand() + 1.0;
                            fire.DrawScale *= 0.5;

                            // necessary?
                            if (fireHasSpawned)
                            {
                                fire.AmbientSound = None;
                            }
                            else
                            {
                                fireHasSpawned = True;
                            }
                        }
                    }
				}
			}
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
