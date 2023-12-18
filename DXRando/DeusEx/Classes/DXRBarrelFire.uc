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

	// trace down to see if we are sitting on the ground
	loc = vect(0,0,0);
	loc.Z -= CollisionHeight + 8.0;
	loc += Location;

	// only generate trash if we are on the ground
	if (!FastTrace(loc))
	{
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
                        loc.X = 0.5*CollisionRadius * (1.0-2.0*FRand());
                        loc.Y = 0.5*CollisionRadius * (1.0-2.0*FRand());
                        loc.Z = 0.6*CollisionHeight * (1.0-2.0*FRand());
                        loc += Location;

                        fire = Spawn(class'SmokelessFire', trash,, loc);
                        if (fire != None)
                        {
                            fire.DrawScale = 0.5*FRand() + 1.0;

                            // //DEUS_EX AMSD Reduce the penalty in multiplayer
                            // if (Level.NetMode != NM_Standalone)
                            //     fire.DrawScale = fire.DrawScale * 0.5;
                            //
                            // // turn off the sound and lights for all but the first one
                            // if (i > 0)
                            // {
                            //     fire.AmbientSound = None;
                            //     fire.LightType = LT_None;
                            // }

                            // turn on/off extra fire and smoke
                            // MP already only generates a little.
                            if ((FRand() < 0.5) && (Level.NetMode == NM_Standalone))
                                fire.smokeGen.Destroy();
                            if ((FRand() < 0.5) && (Level.NetMode == NM_Standalone))
                                fire.AddFire();
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
