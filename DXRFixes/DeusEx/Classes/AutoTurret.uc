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

// we have to copy-paste the whole Tick function just to fix the target selection
function Tick(float deltaTime)
{
    local Pawn pawn;
    local FixScriptedPawn sp;
    local DeusExDecoration deco;
    local float near;
    local Rotator destRot;
    local bool bSwitched;

    // DXRando: skip vanilla AutoTurret Tick
    Super(DeusExDecoration).Tick(deltaTime);

    bSwitched = False;

    if ( bSwitching )
    {
        UpdateSwitch();
        return;
    }

    // Make sure everything is valid and account for when players leave or switch teams
    if ( !bDisabled && (Level.NetMode != NM_Standalone) )
    {
        if ( safeTarget == None )
        {
            bDisabled = True;
            bComputerReset = False;
        }
        else
        {
            if ( DeusExPlayer(safeTarget) != None )
            {
                if ((TeamDMGame(DeusExPlayer(safeTarget).DXGame) != None) && (DeusExPlayer(safeTarget).PlayerReplicationInfo.team != team))
                    bSwitched = True;
                else if ((DeathMatchGame(DeusExPlayer(safeTarget).DXGame) != None ) && (DeusExPlayer(safeTarget).PlayerReplicationInfo.PlayerID != team))
                    bSwitched = True;

                if ( bSwitched )
                {
                    bDisabled = True;
                    safeTarget = None;
                    bComputerReset = False;
                }
            }
        }
    }
    if ( bDisabled && (Level.NetMode != NM_Standalone) )
    {
        team = -1;
        safeTarget = None;
        if ( !bComputerReset )
        {
            gun.ResetComputerAlignment();
            bComputerReset = True;
        }
    }

    if (bConfused)
    {
        confusionTimer += deltaTime;

        // pick a random facing
        if (confusionTimer % 0.25 > 0.2)
        {
            gun.DesiredRotation.Pitch = origRot.Pitch + (pitchLimit / 2 - Rand(pitchLimit));
            gun.DesiredRotation.Yaw = Rand(65535);
        }
        if (confusionTimer > confusionDuration)
        {
            bConfused = False;
            confusionTimer = 0;
            confusionDuration = Default.confusionDuration;
        }
    }

    if (bActive && !bDisabled)
    {
        curTarget = None;

        if ( !bConfused )
        {
            // if we've been EMP'ed, act confused
            if ((Level.NetMode != NM_Standalone) && (Role == ROLE_Authority))
            {
                // DEUS_EX AMSD If in multiplayer, get the multiplayer target.

                if (TargetRefreshTime < 0)
                    TargetRefreshTime = 0;

                TargetRefreshTime = TargetRefreshTime + deltaTime;

                if (TargetRefreshTime >= 0.3)
                {
                    TargetRefreshTime = 0;
                    curTarget = AcquireMultiplayerTarget();
                    if (( curTarget != prevTarget ) && ( curTarget == None ))
                            PlaySound(Sound'TurretUnlocked', SLOT_Interact, 1.0,, maxRange );
                    prevtarget = curtarget;
                }
                else
                {
                    curTarget = prevtarget;
                }
            }
            else
            {
                //
                // Logic table for turrets
                //
                // bTrackPlayersOnly		bTrackPawnsOnly		Should Attack
                // 			T						X				Allies
                //			F						T				Enemies
                //			F						F				Everything
                //

                // Attack allies and neutrals
                if (bTrackPlayersOnly || (!bTrackPlayersOnly && !bTrackPawnsOnly))
                {
                    foreach gun.VisibleActors(class'Pawn', pawn, maxRange, gun.Location)
                    {
                        if (pawn.bDetectable && !pawn.bIgnore)
                        {
                            if (pawn.IsA('DeusExPlayer'))
                            {
                                // If the player's RadarTrans aug is off, the turret can see him
                                if (DeusExPlayer(pawn).AugmentationSystem.GetAugLevelValue(class'AugRadarTrans') == -1.0)
                                {
                                    curTarget = pawn;
                                    break;
                                }
                            }
                            // DXRando: > 0 instead of != ALLIANCE_Hostile
                            else if (pawn.IsA('FixScriptedPawn') && (FixScriptedPawn(pawn).GetPawnAlliance(GetPlayerPawn()) > 0))
                            {
                                curTarget = pawn;
                                break;
                            }
                        }
                    }
                }

                if (!bTrackPlayersOnly)
                {
                    // Attack everything
                    if (!bTrackPawnsOnly)
                    {
                        foreach gun.VisibleActors(class'DeusExDecoration', deco, maxRange, gun.Location)
                        {
                            if (!deco.IsA('ElectronicDevices') && !deco.IsA('AutoTurret') &&
                                !deco.bInvincible && deco.bDetectable && !deco.bIgnore)
                            {
                                curTarget = deco;
                                break;
                            }
                        }
                    }

                    // Attack enemies
                    foreach gun.VisibleActors(class'FixScriptedPawn', sp, maxRange, gun.Location)
                    {
                        // DXRando: < 0 instead of == ALLIANCE_Hostile
                        if (sp.bDetectable && !sp.bIgnore && (sp.GetPawnAlliance(GetPlayerPawn()) < 0))
                        {
                            curTarget = sp;
                            break;
                        }
                    }
                }
            }

            // if we have a target, rotate to face it
            if (curTarget != None)
            {
                destRot = Rotator(curTarget.Location - gun.Location);
                gun.DesiredRotation = destRot;
                near = pitchLimit / 2;
                gun.DesiredRotation.Pitch = FClamp(gun.DesiredRotation.Pitch, origRot.Pitch - near, origRot.Pitch + near);
            }
            else
                gun.DesiredRotation = origRot;
        }
    }
    else
    {
        if ( !bConfused )
            gun.DesiredRotation = origRot;
    }

    near = (Abs(gun.Rotation.Pitch - gun.DesiredRotation.Pitch)) % 65536;
    near += (Abs(gun.Rotation.Yaw - gun.DesiredRotation.Yaw)) % 65536;

    if (bActive && !bDisabled)
    {
        // play an alert sound and light up
        if ((curTarget != None) && (curTarget != LastTarget))
            PlaySound(Sound'Beep6',,,, 1280);

        // if we're aiming close enough to our target
        if (curTarget != None)
        {
            gun.MultiSkins[1] = Texture'RedLightTex';
            if ((near < 4096) && (((Abs(gun.Rotation.Pitch - destRot.Pitch)) % 65536) < 8192))
            {
                if (fireTimer > fireRate)
                {
                    Fire();
                    fireTimer = 0;
                }
            }
        }
        else
        {
            if (gun.IsAnimating())
                gun.PlayAnim('Still', 10.0, 0.001);

            if (bConfused)
                gun.MultiSkins[1] = Texture'YellowLightTex';
            else
                gun.MultiSkins[1] = Texture'GreenLightTex';
        }

        fireTimer += deltaTime;
        LastTarget = curTarget;
    }
    else
    {
        if (gun.IsAnimating())
            gun.PlayAnim('Still', 10.0, 0.001);
        gun.MultiSkins[1] = None;
    }

    // make noise if we're still moving
    if (near > 64)
    {
        gun.AmbientSound = Sound'AutoTurretMove';
        if (bConfused)
            gun.SoundPitch = 128;
        else
            gun.SoundPitch = 64;
    }
    else
        gun.AmbientSound = None;
}

auto state Active
{
    function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
    {
        Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
    }
}
