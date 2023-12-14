class TrashCanCommon extends DXRBase;

static function DestroyTrashCan(Containers trashcan)
{
    local int i;
	local Vector loc;
	local TrashPaper trash;
	local Rat vermin;
    local Containers trashbag;
    local float scale;

	// trace down to see if we are sitting on the ground
	loc = vect(0,0,0);
	loc.Z -= trashcan.CollisionHeight + 8.0;
	loc += trashcan.Location;

	// only generate trash if we are on the ground
	if (!trashcan.FastTrace(loc))
	{
		// maybe spawn some paper
		for (i=0; i<4; i++)
		{
			if (FRand() < 0.75)
			{
				loc = trashcan.Location;
				loc.X += (trashcan.CollisionRadius / 2) - FRand() * trashcan.CollisionRadius;
				loc.Y += (trashcan.CollisionRadius / 2) - FRand() * trashcan.CollisionRadius;
				loc.Z += (trashcan.CollisionHeight / 2) - FRand() * trashcan.CollisionHeight;
				trash = trashcan.Spawn(class'TrashPaper',,, loc);
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
		if (FRand() < 0.42) {
			loc = trashcan.Location;
            if (FRand() < 0.67)
                trashbag = trashcan.Spawn(class'Trashbag',,, loc);
            else
                trashbag = trashcan.Spawn(class'Trashbag2',,, loc);

            if (trashbag != None) {
                scale = trashcan.CollisionRadius / 24.0; // the biggest trashcans have a radius of 24
                if (scale < 1.0)
                    scale = FMin(scale * 1.3, 1.0); // it looks weird if trashbags get too small
                trashbag.SetCollisionSize(trashbag.CollisionRadius * scale, trashbag.CollisionHeight * scale);
                trashbag.drawScale *= scale;
            }
        }

		// maybe spawn a rat
		if (FRand() < 0.14)
		{
			loc = trashcan.Location;
			loc.Z -= trashcan.CollisionHeight;
			vermin = trashcan.Spawn(class'Rat',,, loc);
			if (vermin != None)
				vermin.bTransient = true;
		}
	}
}
