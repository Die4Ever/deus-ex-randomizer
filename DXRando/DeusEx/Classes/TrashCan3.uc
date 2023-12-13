class DXRTrashCan3 injects #var(prefix)TrashCan3;

defaultproperties
{
     bGenerateTrash=False
}

function Destroyed()
{
	local int i;
	local Rotator rot;
	local Vector loc;
	local TrashPaper trash;
	local Rat vermin;
    local TrashBag trashbag;

	// trace down to see if we are sitting on the ground
	loc = vect(0,0,0);
	loc.Z -= CollisionHeight + 8.0;
	loc += Location;

	// only generate trash if we are on the ground
	if (!FastTrace(loc))
	{
		// maybe spawn some paper
		for (i=0; i<4; i++)
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

        // maybe spawn a trashbag
		if (/*FRand() < 0.42*/True) {
			loc = Location;
			loc.Z += 0; // it looks weird for the about equally sized trashbag to just replace the can
			trashbag = Spawn(class'Trashbag',,, loc);
        }

		// maybe spawn a rat
		if (FRand() < 0.14)
		{
			loc = Location;
			loc.Z -= CollisionHeight;
			vermin = Spawn(class'Rat',,, loc);
			if (vermin != None)
				vermin.bTransient = true;
		}
	}

    Super.Destroyed();
}
