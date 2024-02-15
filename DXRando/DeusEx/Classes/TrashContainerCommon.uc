class TrashContainerCommon extends DXRBase abstract;

static function DestroyTrashCan(#var(prefix)Containers trashcan, class<#var(prefix)Containers> trashBagType)
{
	local Vector loc;
	local #var(prefix)Rat vermin;
    local #var(prefix)Containers trashbag;
    local float scale, scaleCorrection;

    // maybe spawn a trashbag
    if (FRand() < 0.8)
    {
        // less likely maybe spawn some trashpaper (50% chance of at least one)
        GenerateTrashPaper(trashcan, 0.16);

        loc = trashcan.Location;
        trashbag = trashcan.Spawn(trashBagType,,, loc);

        if (trashbag != None)
        {
            scale = 1.0;
            // trashbags that are too big look weird when dropped, but ones whose
            // default radius is smaller are fine, at least with vanilla ratios
            if (trashbag.default.CollisionRadius > trashcan.default.CollisionRadius)
            {
                // get the proportional difference in their default radii
                scaleCorrection = 1.0 - (trashcan.default.CollisionRadius / trashbag.default.CollisionRadius);
                // square the difference so that larger differences have a reatively larger effect, then reduce it a bit
                scaleCorrection = 0.875 * scaleCorrection * scaleCorrection;
                // subtract the reduced difference from the starting scale
                scale -= scaleCorrection;
            }
            // scale the trashbag scale by how much the trashcan has been scaled
            scale *= trashcan.CollisionRadius / trashcan.default.CollisionRadius;

            // scale the trashbag by the final scale value
            trashbag.SetCollisionSize(trashbag.CollisionRadius * scale, trashbag.CollisionHeight * scale);
            trashbag.drawScale *= scale;
        }
    }
    else
    {
        // more likely maybe spawn some trashpaper (94% chance of at least one)
        GenerateTrashPaper(trashcan, 0.5);

        // maybe spawn a rat, but not if underwater
        if (!trashcan.Region.Zone.bWaterZone && FRand() < 0.17) // creates a final 50% chance of getting a rat
        {
            loc = trashcan.Location;
            loc.Z -= trashcan.CollisionHeight;
            vermin = trashcan.Spawn(class'#var(prefix)Rat',,, loc);
            if (vermin != None)
                vermin.bTransient = true;
        }
    }
}

static function GenerateTrashPaper(#var(prefix)Containers trashContainer, float probability, optional bool onFire)
{
	local Vector loc;
    local int i;
	local #var(prefix)TrashPaper trashPaper;
    local int numPaperChances;
	local Fire fire;

    onFire = onFire || trashContainer.IsInState('Burning');

    if (onFire) {
        numPaperChances = 3;
    }
    else {
        numPaperChances = 4;
    }

    // trace down to see if we are sitting on the ground
	loc = vect(0,0,0);
	loc.Z -= trashContainer.CollisionHeight + 8.0;
	loc += trashContainer.Location;

	// only generate trashpaper if we're on the ground
	if (!trashContainer.FastTrace(loc)) {
		for (i=0; i < numPaperChances; i++) {
			if (FRand() < probability) {
				loc = trashContainer.Location;
				loc.X += (trashContainer.CollisionRadius / 2) - FRand() * trashContainer.CollisionRadius;
				loc.Y += (trashContainer.CollisionRadius / 2) - FRand() * trashContainer.CollisionRadius;
				loc.Z += (trashContainer.CollisionHeight / 2) - FRand() * trashContainer.CollisionHeight;
				trashPaper = trashContainer.Spawn(class'#var(prefix)TrashPaper',,, loc);
				if (trashPaper != None) {
					trashPaper.SetPhysics(PHYS_Rolling);
					trashPaper.rot = RotRand(True);
					trashPaper.rot.Yaw = 0;
					trashPaper.dir = VRand() * 20 + vect(20,20,0);
					trashPaper.dir.Z = 0;

                    if (onFire && FRand() < 0.5) {
                        fire = trashPaper.Spawn(class'SmokelessFire', trashPaper,, loc);
                        // FireSmall2 is quieter than FireSmall1, which is used by burning trash containers.
                        // It might be too quiet though.
                        fire.AmbientSound = Sound'Ambient.Ambient.FireSmall2';
                        if (fire != None) {
                            fire.DrawScale = 0.25*FRand() + 0.5;
                        }
                    }
				}
			}
		}
	}
}
