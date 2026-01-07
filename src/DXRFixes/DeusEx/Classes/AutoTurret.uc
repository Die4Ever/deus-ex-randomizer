class AutoTurret injects AutoTurret;

var float crazedTimer;
var bool bTrackPawnsOnlyOrig;
var bool bTrackPlayersOnlyOrig;
var bool bActiveOrig;

var float scramblerDamageMult;

enum ETurretBehaviour
{
    TB_Stationary, //Vanilla behaviour
    TB_Swing,      //Gentle swing back and forth
    TB_RandomLook  //Randomly look around
};

//Swing logic
var() ETurretBehaviour activeBehaviour; //What should the turret do while active
var() float swingMaxAngle;   //The maximum angle (in Unreal units) it should swing to either side
var() float swingTime;       //The amount of time it should take to swing from side to side
var() float swingBaseYaw;    //if you want the swing to be centred around a different rotation than origRot for whatever reason
var() float swingSkew;       //How much to adjust the centre of the swing range from the original rotation
var   float activeTime;

var DynamicLight statusLight;

const defSwingTime = 10.0;
const defSwingMaxAngle = 8192; //  +/- 45 degrees

const defRandLookSwingTime = 1.5;
const defRandLookMaxAngle = 11833; //  +/- ~65 degrees

function PreBeginPlay()
{
    Super.PreBeginPlay();

    if(class'MenuChoice_BalanceEtc'.static.IsEnabled()) {
        //Make turrets swing when active when Etc balance changes are
        activeBehaviour=TB_Swing;
        SetDefaultSwingBehaviours();
        CalcBestOrigRot();

        //Make a small spotlight that shines the colour of the light on the front of the turret
        //Currently disabled - The spotlight effect goes through walls and hits actors in a radius
        //regardless of the LightEffect setting.
        //CreateStatusLight();
    }
}

function CreateStatusLight()
{
    statusLight = Spawn(class'DynamicLight',,, gun.Location);
    statusLight.SetBase(gun);
    statusLight.LightType=LT_None;
    statusLight.LightEffect=LE_Spotlight;
    statusLight.LightRadius=32;
    statusLight.LightCone=32;
    statusLight.LightBrightness=32;
    statusLight.LightSaturation=0;

}

function UpdateStatusLightColour()
{
    local Rotator lightRot;
    local Vector  lightLoc;

    if (statusLight==None || statusLight.bDeleteMe) return;

    lightRot = gun.Rotation;
    statusLight.SetRotation(lightRot);
    lightLoc = gun.Location + (class'DXRBase'.static.MakeVector(gun.CollisionRadius+0.5,0,0) >> lightRot);
    statusLight.SetLocation(lightLoc);

    switch(gun.MultiSkins[1])
    {
        case Texture'GreenLightTex':
            statusLight.LightType=LT_Steady;
            statusLight.LightHue=89;
            break;
        case Texture'YellowLightTex':
            statusLight.LightType=LT_Steady;
            statusLight.LightHue=75;
            break;
        case Texture'RedLightTex':
            statusLight.LightType=LT_Steady;
            statusLight.LightHue=255;
            break;
        case None:
        default:
            statusLight.LightType=LT_None;
            break;
    }
}

function Destroyed()
{
    if (statusLight!=None) statusLight.Destroy();
    Super.Destroyed();
}

function float GetSwingTimeScaleFactor(float newAngle)
{
    switch(activeBehaviour){
        case TB_Swing:
            return Max(1.0,newAngle/defSwingMaxAngle);
        case TB_RandomLook:
            return Max(1.0,newAngle/defRandLookMaxAngle);
    }
    return 1.0;
}


//A lot of AutoTurrets are really badly rotated.  Poke around a bit to see what rotations
//seem most reasonable...  Check in increments to see what directions seem the most open.
function CalcBestOrigRot()
{
    //local float dists[8];
    local float dists[32];
    local Rotator testRotDir;
    local float yawIncrement,lowestDist,highestDist, origRotDist, SwingThreshold, SwingAmount, CentreAdjust;
    local int i, idx, lowestDistIdx, highestDistIdx, lowExtent, highExtent;

    local vector HitLocation, HitNormal,EndTrace;
    local Actor HitActor;
    local bool setOrigRot;

    //Turrets attached to movers are probably tucked away, or something
    //Trust the level designer hopefully aimed it in roughly the right direction.
    if (#var(DeusExPrefix)Mover(Base)!=None) return;

    yawIncrement = 65536/ArrayCount(dists);
    //ProbeDistance = 5000.0;
    SwingThreshold = 0.25;

    lowestDistIdx=0;
    highestDistIdx=0;

    //Check the distance in each direction
    for (i=0;i<ArrayCount(dists);i++)
    {
        testRotDir.Yaw = yawIncrement * i;

        EndTrace = gun.Location + (class'DXRBase'.static.MakeVector(maxRange,0,0) >> testRotDir);
        HitActor = gun.Trace(HitLocation, HitNormal, EndTrace,gun.Location, false);

        if (HitActor==None){
            dists[i]=maxRange;
        }
        else if (HitActor==Level)
        {
            dists[i]=VSize(HitLocation-gun.Location);
        }

        if (dists[i] < dists[lowestDistIdx])
        {
            lowestDistIdx = i;
        }

        if (dists[i] > dists[highestDistIdx])
        {
            highestDistIdx = i;
        }
    }

    //Also calculate the distance in the actual original rotation
    EndTrace = gun.Location + (class'DXRBase'.static.MakeVector(maxRange,0,0) >> origRot);
    HitActor = gun.Trace(HitLocation, HitNormal, EndTrace,gun.Location, false);

    if (HitActor==None){
        origRotDist=maxRange;
    }
    else if (HitActor==Level)
    {
        origRotDist=VSize(HitLocation-gun.Location);
    }


    lowestDist = dists[lowestDistIdx];
    highestDist = dists[highestDistIdx];


    //Convert all distances into a score between 0 (the lowest distance) and 1 (the highest distance)
    for (i=0;i<ArrayCount(dists);i++)
    {
        dists[i]=(dists[i]-lowestDist)/(highestDist-lowestDist);
    }

    //and the original rotation distance
    origRotDist=(origRotDist-lowestDist)/(highestDist-lowestDist);

    if (origRotDist > 0.9) {
        //If the original rotation is at least semi-decent, maybe the map maker did this intentionally?
        //Don't change the original rotation at all.
        setOrigRot=false;
    } else {
        setOrigRot=true;
    }

    //TODO: We could determine an ideal swing range using the scores calculated above.  Work out from
    //the longest distance and find the angles where the scores drop below some threshold (0.7?).
    //from there, you know the extents of the swing.  Use the centre angle of those extents as the
    //origRot, and set the swing angle equal to the distance between the centre angle and the extent.

    //Find low extent
    //lowExtent, highExtent
    log(self$" HighestDistIdx="$highestDistIdx);
    idx = highestDistIdx;
    lowExtent = 0;
    for (i=0;i < ArrayCount(dists);i++){
        log(self$" lowExtentIdx="$idx$"  Score: "$dists[idx]);
        if (dists[idx] >= SwingThreshold){
            lowExtent = i; //How many steps below
        } else {
            //Below the threshold, we've found the extent
            break;
        }
        idx--;
        if (idx <0) idx = ArrayCount(dists)-1;
    }

    //Find the high extent
    idx = highestDistIdx;
    highExtent = 0;
    for (i=0;i < ArrayCount(dists);i++){
        log(self$" highExtentIdx="$idx$"  Score: "$dists[idx]);
        if (dists[idx] >= SwingThreshold){
            highExtent = i; //How many steps above
        } else {
            //Below the threshold, we've found the extent
            break;
        }
        idx++;
        if (idx >= ArrayCount(dists) ) idx = 0;
    }

    log(self$" highExtent="$highExtent$"  LowExtent="$lowExtent);

    testRotDir.Yaw = yawIncrement * highestDistIdx;

    //Incorporate extents...
    SwingAmount = ((highExtent + LowExtent) * yawIncrement) / 2;

    swingMaxAngle = SwingAmount;

    //Scale SwingTime as well, based on the new swingMaxAngle
    swingtime = swingTime * GetSwingTimeScaleFactor(SwingAmount);

    //adjust centre down to bottom of low extent, then move halfway through the range
    CentreAdjust = -(lowExtent * yawIncrement) + (SwingAmount);
    testRotDir.Yaw += CentreAdjust;
    if (setOrigRot){
        SetNewOrigRot(testRotDir);
    } else {
        swingBaseYaw = testRotDir.Yaw;
    }
}

function SetNewOrigRot(Rotator r)
{
    origRot = r;
    if (gun!=None){
        gun.DesiredRotation = r;
        gun.SetRotation(r);
    }
}

function ForceDefaultSwingBehaviour()
{
    swingTime=0;
    swingMaxAngle=0;
    swingBaseYaw=0;
    SetDefaultSwingBehaviours();
}

function SetDefaultSwingBehaviours()
{
    if (swingTime<=0){
        if (activeBehaviour==TB_Swing){
            swingTime=defSwingTime;
        } else if (activeBehaviour==TB_RandomLook){
            swingTime=defRandLookSwingTime;
        }
    }

    if (swingMaxAngle<=0){
        if (activeBehaviour==TB_Swing){
            swingMaxAngle=defSwingMaxAngle;
        } else if (activeBehaviour==TB_RandomLook){
            swingMaxAngle=defRandLookMaxAngle;
        }
    }

    swingTime = swingTime + ( (FRand()*(swingTime/10.0)) - ((swingTime/10.0)/2.0)); //Time to swing isn't quite the same speed on every turret (vary by +/- 5%)

}

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
    local Rotator destRot, swingRot;
    local bool bSwitched, shouldMove;

    // DXRando: skip vanilla AutoTurret Tick
    Super(DeusExDecoration).Tick(deltaTime);

    if (CrazedTimer > 0)
	{
        CrazedTimer -= deltaTime;
		if (CrazedTimer < 0) {
            //Revert craziness
			CrazedTimer = 0;
            bTrackPawnsOnly = bTrackPawnsOnlyOrig;
            bTrackPlayersOnly = bTrackPlayersOnlyOrig;
            bActive = bActiveOrig;
        }
	}


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
            {
                if (activeBehaviour==TB_Stationary){
                    gun.DesiredRotation = origRot;
                }
            }

        }
    }
    else
    {
        if ( !bConfused )
            gun.DesiredRotation = origRot;
    }

    //New logic to make active turrets more obvious by making them move while active
    if (activeBehaviour!=TB_Stationary)
    {
        if (bActive && curTarget==None && !bDisabled && !bConfused){
            activeTime += deltaTime;
            shouldMove = false;

            if (activeBehaviour==TB_Swing){
                shouldMove = true; //Always swing

                swingRot = origRot;
                if (swingBaseYaw!=0){
                    swingRot.Yaw = swingBaseYaw;
                }
                swingRot.Yaw += swingSkew + ( Sin( 2*pi * activeTime/swingTime ) * swingMaxAngle );

            } else if (activeBehaviour==TB_RandomLook){
                if (activeTime > swingTime){
                    activeTime = 0.0;

                    shouldMove = true;

                    swingRot = origRot;
                    if (swingBaseYaw!=0){
                        swingRot.Yaw = swingBaseYaw;
                    }

                    //Pick a random angle in the range
                    swingRot.Yaw += swingSkew + ( Cos( 2*pi * (FRand())) * swingMaxAngle );

                }
            }

            if (shouldMove){
                gun.DesiredRotation = swingRot;
            }
        } else {
            activeTime=0.0;
        }
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

    //DXRando
    UpdateStatusLightColour();

    // make noise if we're still moving
    if (near > 64 || (activeBehaviour!=TB_Stationary && shouldMove))
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

function HandleScrambler(Pawn instigator, int damage)
{
    local bool bTrackPawnsDesired;
    local bool bTrackPlayersDesired;
    local ScriptedPawn sp;

    sp = ScriptedPawn(instigator);

    if (sp!=None){
        if (sp.GetAllianceType('Player')==ALLIANCE_Hostile){
            bTrackPawnsDesired = False;
            bTrackPlayersDesired = True;
        } else {
            bTrackPawnsDesired = True;
            bTrackPlayersDesired = False;
        }
    } else {
        bTrackPawnsDesired = True;
        bTrackPlayersDesired = False;
    }

    if (bTrackPawnsOnly == bTrackPawnsDesired && bTrackPlayersOnly == bTrackPlayersDesired){
        //No alliance changing necessary
        CrazedTimer += scramblerDamageMult*Damage;
        return;
    }

    if (CrazedTimer <=0) {
        bTrackPawnsOnlyOrig = bTrackPawnsOnly;
        bTrackPlayersOnlyOrig = bTrackPlayersOnly;
        bActiveOrig = bActive;
    }

    //Robots use half the damage
    //Note that turrets will be hit twice for every hit,
    //since both the base (this) and the gun can be hit,
    //and the gun will pass the damage to the base.
    //The scramblerDamageMult is lower to compensate for this.
    CrazedTimer += scramblerDamageMult*Damage;
    bTrackPawnsOnly = bTrackPawnsDesired;
    bTrackPlayersOnly = bTrackPlayersDesired;
    bActive = True;

}

function SetSwingBaseYaw(float yaw)
{
    local Rotator swingRot;
    local DXRActorsBase dxrab;

    dxrab = DXRActorsBase(class'DXRActorsBase'.static.Find());

    swingRot=dxrab.rotm(0,yaw,0,dxrab.GetRotationOffset(self.class));

    swingBaseYaw=swingRot.yaw;
}

function SetSwingSkew(float yaw)
{
    local Rotator swingRot;
    local DXRActorsBase dxrab;

    dxrab = DXRActorsBase(class'DXRActorsBase'.static.Find());

    swingRot=dxrab.rotm(0,yaw,0,dxrab.GetRotationOffset(self.class));

    swingSkew=swingRot.yaw;
}

function MakeTurretSwing(optional float newSwingTime, optional float newMaxSwingAngle)
{
    swingTime=newSwingTime;
    swingMaxAngle =newMaxSwingAngle;
    activeBehaviour=TB_Swing;
    SetDefaultSwingBehaviours();
}

function MakeTurretRandomLook(optional float newSwingTime, optional float newMaxSwingAngle)
{
    swingTime=newSwingTime;
    swingMaxAngle =newMaxSwingAngle;
    activeBehaviour=TB_RandomLook;
    SetDefaultSwingBehaviours();
}

auto state Active
{
    function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
    {
        if (DamageType == 'NanoVirus') {

            HandleScrambler(EventInstigator,Damage);
        }

        Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
    }
}

defaultproperties
{
     scramblerDamageMult=0.2
     activeBehaviour=TB_Stationary
     //activeBehaviour=TB_Swing
     //activeBehaviour=TB_RandomLook
}
