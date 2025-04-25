class DXRMission06 injects Mission06;

function FireMissilesAt(name targetTag)
{
	local int i;
	local Vector loc;
	local BlackHelicopter chopper;
	local RocketLAW rocket;
	local Actor A, Target;

	foreach AllActors(class'Actor', A, targetTag)
		Target = A;

	// fire missiles from the helicopter
	foreach AllActors(class'BlackHelicopter', chopper, 'chopper')
	{
		for (i=-1; i<=1; i+=2)
		{
			loc = (i*chopper.CollisionRadius * vect(0,0.15,0)) >> chopper.Rotation;
			loc += chopper.Location;
			rocket = Spawn(class'RocketLAW', chopper,, loc, chopper.Rotation);
			if (rocket != None)
			{
				rocket.bTracking = True;
				rocket.Target = Target;
                rocket.blastRadius = 192;  //Decrease blast radius
				rocket.PlaySound(sound'RocketIgnite', SLOT_None, 2.0,, 2048);
			}
		}
	}
}
