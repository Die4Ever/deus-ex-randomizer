class DXRLaserEmitter injects #var(prefix)LaserEmitter;
// used by both BeamTrigger and LaserTrigger

// make sure death markers don't block lasers, continue tracing through them
function CalcTrace(float deltaTime)
{
    local vector StartTrace, EndTrace, HitLocation, HitNormal, Reflection;
    local actor target;
    local int i, texFlags;
    local name texName, texGroup;

    StartTrace = Location;
    EndTrace = Location + 5000 * vector(Rotation);
    HitActor = None;

    // trace the path of the reflected beam and draw points at each hit
    for (i=0; i<ArrayCount(spot); i++)
    {
        foreach TraceTexture(class'Actor', target, texName, texGroup, texFlags, HitLocation, HitNormal, EndTrace, StartTrace)
        {
            if (   target.DrawType == DT_None
                || target.bHidden
                || target.IsA('DeathMarker')
                || (DeusExProjectile(target) != None && !DeusExProjectile(target).bStuck)
                || !target.bBlockActors
            ) {
                // do nothing - keep on tracing
            }
            else if ((target == Level) || target.IsA('Mover'))
            {
                break;
            }
            else
            {
                HitActor = target;
                break;
            }
        }

        // draw first beam
        if (i == 0)
        {
            if (LaserIterator(RenderInterface) != None)
                LaserIterator(RenderInterface).AddBeam(i, Location, Rotation, VSize(Location - HitLocation));
        }
        else
        {
            if (LaserIterator(RenderInterface) != None)
                LaserIterator(RenderInterface).AddBeam(i, StartTrace - HitNormal, Rotator(Reflection), VSize(StartTrace - HitLocation - HitNormal));
        }

        if (spot[i] == None)
        {
            spot[i] = Spawn(class'LaserSpot', Self, , HitLocation, Rotator(HitNormal));
            if (bBlueBeam && (spot[i] != None))
                spot[i].Skin = Texture'LaserSpot2';
        }
        else
        {
            spot[i].SetLocation(HitLocation);
            spot[i].SetRotation(Rotator(HitNormal));
        }

        // don't reflect any more if we don't hit a mirror
        // 0x08000000 is the PF_Mirrored flag from UnObj.h
        if ((texFlags & 0x08000000) == 0)
        {
            // kill all of the other spots after this one
            if (i < ArrayCount(spot)-1)
            {
                do
                {
                    i++;
                    if (spot[i] != None)
                    {
                        spot[i].Destroy();
                        spot[i] = None;
                        if (LaserIterator(RenderInterface) != None)
                            LaserIterator(RenderInterface).DeleteBeam(i);
                    }
                } until (i>=ArrayCount(spot)-1);
            }

            return;
        }

        Reflection = MirrorVectorByNormal(Normal(HitLocation - StartTrace), HitNormal);
        StartTrace = HitLocation + HitNormal;
        EndTrace = Reflection * 10000;
    }
}
