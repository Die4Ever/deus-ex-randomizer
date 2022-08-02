class DXRElectricityEmitter injects #var(prefix)ElectricityEmitter;

// make sure sprites don't block electricity (smoke, death markers), continue tracing through them
function CalcTrace(float deltaTime)
{
    local vector StartTrace, EndTrace, HitLocation, HitNormal, loc;
    local Rotator rot;
    local actor target;
    local int texFlags;
    local name texName, texGroup;

    if (!bHiddenBeam)
    {
        // set up the random beam stuff
        rot.Pitch = Int((0.5 - FRand()) * randomAngle);
        rot.Yaw = Int((0.5 - FRand()) * randomAngle);
        rot.Roll = Int((0.5 - FRand()) * randomAngle);

        StartTrace = Location;
        EndTrace = Location + 5000 * vector(Rotation + rot);
        HitActor = None;

        foreach TraceTexture(class'Actor', target, texName, texGroup, texFlags, HitLocation, HitNormal, EndTrace, StartTrace)
        {
            if (target.DrawType == DT_None || target.DrawType == DT_Sprite || target.bHidden)
            {
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

        lastDamageTime += deltaTime;

        // shock whatever gets in the beam
        if ((HitActor != None) && (lastDamageTime >= damageTime))
        {
            HitActor.TakeDamage(damageAmount, Instigator, HitLocation, vect(0,0,0), 'Shocked');
            lastDamageTime = 0;
        }

        if (LaserIterator(RenderInterface) != None)
            LaserIterator(RenderInterface).AddBeam(0, Location, Rotation + rot, VSize(Location - HitLocation));
    }
}
