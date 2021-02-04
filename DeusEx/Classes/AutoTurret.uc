class AutoTurret injects AutoTurret;

//DXR: don't blame the player for turrets they don't control
function Fire()
{
    local Vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
    local Rotator rot;
    local Actor hit;
    local ShellCasing shell;
    local Spark spark;
    local Pawn attacker;

    if (!gun.IsAnimating())
        gun.LoopAnim('Fire');

    // CNN - give turrets infinite ammo
    //	if (ammoAmount > 0)
    //	{
    //		ammoAmount--;
    GetAxes(gun.Rotation, X, Y, Z);
    StartTrace = gun.Location;
    EndTrace = StartTrace + gunAccuracy * (FRand()-0.5)*Y*1000 + gunAccuracy * (FRand()-0.5)*Z*1000 ;
    EndTrace += 10000 * X;
    hit = Trace(HitLocation, HitNormal, EndTrace, StartTrace, True);

    // spawn some effects
    if ((DeusExMPGame(Level.Game) != None) && (!DeusExMPGame(Level.Game).bSpawnEffects))
    {
        shell = None;
    }
    else
    {
        shell = Spawn(class'ShellCasing',,, gun.Location);
    }
    if (shell != None)
        shell.Velocity = Vector(gun.Rotation - rot(0,16384,0)) * 100 + VRand() * 30;

    MakeNoise(1.0);
    PlaySound(sound'PistolFire', SLOT_None);
    AISendEvent('LoudNoise', EAITYPE_Audio);

    // muzzle flash
    gun.LightType = LT_Steady;
    gun.MultiSkins[2] = Texture'FlatFXTex34';
    SetTimer(0.1, False);

    // randomly draw a tracer
    if (FRand() < 0.5)
    {
        if (VSize(HitLocation - StartTrace) > 250)
        {
            rot = Rotator(EndTrace - StartTrace);
            Spawn(class'Tracer',,, StartTrace + 96 * Vector(rot), rot);
        }
    }

    if (hit != None)
    {
        if ((DeusExMPGame(Level.Game) != None) && (!DeusExMPGame(Level.Game).bSpawnEffects))
        {
            spark = None;
        }
        else
        {
            // spawn a little spark and make a ricochet sound if we hit something
            spark = spawn(class'Spark',,,HitLocation+HitNormal, Rotator(HitNormal));
        }

        if (spark != None)
        {
            spark.DrawScale = 0.05;
            PlayHitSound(spark, hit);
        }

        attacker = None;
        //DXRando adds "bTrackPlayersOnly==false &&" here because we don't want to blame the player for turrets they don't control
        if ( bTrackPlayersOnly==false && (curTarget == hit) && !curTarget.IsA('PlayerPawn'))
            attacker = GetPlayerPawn();
        if (Level.NetMode != NM_Standalone)
            attacker = safetarget;
        if ( hit.IsA('DeusExPlayer') && ( Level.NetMode != NM_Standalone ))
            DeusExPlayer(hit).myTurretKiller = Self;
        hit.TakeDamage(gunDamage, attacker, HitLocation, 1000.0*X, 'AutoShot');

        if (hit.IsA('Pawn') && !hit.IsA('Robot'))
            SpawnBlood(HitLocation, HitNormal);
        else if ((hit == Level) || hit.IsA('Mover'))
            SpawnEffects(HitLocation, HitNormal, hit);
    }
    //	}
    //	else
    //	{
    //		PlaySound(sound'DryFire', SLOT_None);
    //	}
}
