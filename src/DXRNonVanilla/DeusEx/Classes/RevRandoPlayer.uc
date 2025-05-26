#compileif revision
class RevRandoPlayer extends RevJCDentonMale;

var laserEmitter aimLaser;
var bool bDoomMode;
var bool bOnLadder;
var Rotator ShakeRotator;

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
    local float augLevel;
    local bool headGone, torsoGone, leftLegGone, rightLegGone, LeftArmGone, rightArmGone;

    if(Level.LevelAction != LEVACT_None) return;

    if(damageType == 'NanoVirus' && class'MenuChoice_BalanceEtc'.static.IsEnabled()) {
        augLevel = -1;
        if (AugmentationSystem != None)
            augLevel = AugmentationSystem.GetAugLevelValue(class'AugEMP');
        if(augLevel == -1) {
            RandomizeAugStates();
        }
        else {
            AddDamageDisplay('NanoVirus', vect(0,0,0));
            SetDamagePercent(1);
        }
    } else if (damageType=='Shot' || damageType=='AutoShot'){
        if (WineBulletsActive()){
            drugEffectTimer+=3.0;
        }
    }

    headGone     = HealthHead     <= 0;
    torsoGone    = HealthTorso    <= 0;
    leftLegGone  = HealthLegLeft  <= 0;
    rightLegGone = HealthLegRight <= 0;
    leftArmGone  = HealthArmLeft  <= 0;
    rightArmGone = HealthArmRight <= 0;

    Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);

    if (!headGone && HealthHead <= 0)         MarkBodyPartLoss("Head");
    if (!torsoGone && HealthTorso <= 0)       MarkBodyPartLoss("Torso");
    if (!leftLegGone && HealthLegLeft <= 0)   MarkBodyPartLoss("LeftLeg");
    if (!rightLegGone && HealthLegRight <= 0) MarkBodyPartLoss("RightLeg");
    if (!leftArmGone && HealthArmLeft <= 0)   MarkBodyPartLoss("LeftArm");
    if (!rightArmGone && HealthArmRight <= 0) MarkBodyPartLoss("RightArm");
}

function MarkBodyPartLoss(string part)
{
    class'DXRStats'.static.AddBodyPartLoss(self,part);
    class'DXREvents'.static.MarkBingo("BodyPartLoss_"$part);

    //All right, we'll call it a draw!
    if (HealthLegLeft <= 0 &&
        HealthLegRight <= 0 &&
        HealthArmLeft <= 0 &&
        HealthArmRight <= 0 &&
        HealthTorso > 0 &&
        HealthHead > 0) {

        class'DXREvents'.static.MarkBingo("JustAFleshWound");
    }

}

function RandomizeAugStates()
{
    local Augmentation aug;
    local DXRBase dxrb;

    for(aug = AugmentationSystem.FirstAug; aug!=None; aug = aug.next){

        //Skip synthetic heart since deactivating it turns off all your augs
        //(Maybe this could only skip it for deactivation?)
        if (aug.bHasIt && !aug.bAlwaysActive && (AugHeartLung(aug)==None)) {
            if (rand(2)==0){
                if (aug.bIsActive){
                    aug.Deactivate();
                } else {
                    aug.Activate();
                }
            }
        }
    }
    AugmentationSystem.RefreshAugDisplay();
}

function bool WineBulletsActive()
{
    local DataStorage datastorage;

    if (!class'DXRFlags'.default.bCrowdControl) return False;

    datastorage = class'DataStorage'.static.GetObjFromPlayer(self);
    return bool(datastorage.GetConfigKey('cc_WineBullets'));
}

// ----------------------------------------------------------------------
// DXReduceDamage()
//
// Calculates reduced damage from augmentations and from inventory items
// Also calculates a scalar damage reduction based on the mission number
// ----------------------------------------------------------------------
function bool DXReduceDamage(int Damage, name damageType, vector hitLocation, out int adjustedDamage, bool bCheckOnly)
{
    local float newDamage, oldDamage;
    local float augLevel, skillLevel;
    local float pct;
    local HazMatSuit suit;
    local BallisticArmor armor;
    local bool bReduced;
    local float damageMult;

    augLevel = -1;

    bReduced = False;
    newDamage = Float(Damage);
    newDamage = AdjustCritSpots(newDamage, damageType, hitLocation);
    oldDamage = newDamage;

    newDamage = ReduceEnviroDamage(newDamage, damageType);

    if ((damageType == 'Shot') || (damageType == 'Sabot') || (damageType == 'Exploded') || (damageType == 'AutoShot'))
    {
        newDamage = ArmorReduceDamage(newDamage);
    }

    if (damageType == 'HalonGas')
    {
        if (bOnFire && !bCheckOnly)
            ExtinguishFire();
    }

    if ((damageType == 'Shot') || (damageType == 'AutoShot'))
    {
        if (AugmentationSystem != None)
            augLevel = AugmentationSystem.GetAugLevelValue(class'AugBallistic');

        if (augLevel >= 0.0)
            newDamage *= augLevel;
    }

    if (damageType == 'EMP')
    {
        if (AugmentationSystem != None)
            augLevel = AugmentationSystem.GetAugLevelValue(class'AugEMP');

        if (augLevel >= 0.0)
            newDamage *= augLevel;
    }

    if ((damageType == 'Burned') || (damageType == 'Flamed') ||
        (damageType == 'Exploded') || (damageType == 'Shocked'))
    {
        if (AugmentationSystem != None)
            augLevel = AugmentationSystem.GetAugLevelValue(class'AugShield');

        if (augLevel >= 0.0)
            newDamage *= augLevel;
    }

    //Apply damage multiplier
    //This gets tweaked from DXRandoCrowdControlLink, but will normally just be 1.0
    damageMult = GetDamageMultiplier();
    if (damageMult!=0) {
        newDamage*=damageMult;
    }

    // show resistance, don't factor in the random rounding, so the numbers are stable and easier to read
    pct = 1.0 - (newDamage / oldDamage);
    if (!bCheckOnly)
    {
        SetDamagePercent(pct);
    }
    if( pct > 0 ) {
        bReduced = True;
        ClientFlash(0.01, vect(0, 0, 50));
    }

    //
    // Reduce or increase the damage based on the combat difficulty setting, do this before SetDamagePercent for the UI display
    // because we don't want to show 100% damage reduction but then do the minimum of 1 damage
    if (damageType == 'Shot' || damageType == 'AutoShot')
    {
        newDamage *= CombatDifficulty;
        oldDamage *= CombatDifficulty;
    }
    else if((damageType == 'Flamed' || damageType == 'Burned') && class'MenuChoice_BalanceEtc'.static.IsEnabled()) {
        newDamage *= CombatDifficulty;
        oldDamage *= CombatDifficulty;
    }
    else if (damageType != 'fell' && damageType != 'Drowned' && class'MenuChoice_BalanceEtc'.static.IsEnabled()) {
        damageMult = CombatDifficultyMultEnviro();
        newDamage *= damageMult;
        oldDamage *= damageMult;
    }

    if(frand() < (newDamage%1.0)) {// DXRando: random rounding, 1.9 is more likely to round up than 1.1 is
        newDamage += 0.999;
        oldDamage += 0.999;
    }

    adjustedDamage = Int(newDamage);// adjustedDamage is our out param

    if(damageType == 'TearGas' && adjustedDamage*2 >= HealthTorso && class'MenuChoice_BalanceEtc'.static.IsEnabled()) {
        // TearGas can't kill you
        adjustedDamage = 0;
        HealthTorso = 1;
    }

    return bReduced;
}

function float CombatDifficultyMultEnviro()
{
    return (CombatDifficulty*0.2) + 0.8;// 20% wet / 80% dry
}

function float GetDamageMultiplier()
{
    local DataStorage datastorage;

    if (!class'DXRFlags'.default.bCrowdControl) return 0;

    datastorage = class'DataStorage'.static.GetObjFromPlayer(self);
    return float(datastorage.GetConfigKey('cc_damageMult'));
}

function float AdjustCritSpots(float Damage, name damageType, vector hitLocation)
{
    local vector offset;
    local float headOffsetZ, headOffsetY, armOffset;

    // EMP attacks drain BE energy
    if (damageType == 'EMP')
        return Damage;

    // use the hitlocation to determine where the pawn is hit
    // transform the worldspace hitlocation into objectspace
    // in objectspace, remember X is front to back
    // Y is side to side, and Z is top to bottom
    offset = (hitLocation - Location) << Rotation;

    // calculate our hit extents
    headOffsetZ = CollisionHeight * 0.78;
    headOffsetY = CollisionRadius * 0.35;
    armOffset = CollisionRadius * 0.35;

    // We decided to just have 3 hit locations in multiplayer MBCODE
    if (( Level.NetMode == NM_DedicatedServer ) || ( Level.NetMode == NM_ListenServer ))
    {
        // leave it vanilla
        return Damage;
    }

    // Normal damage code path for single player
    if (offset.z > headOffsetZ)     // head
    {
        // narrow the head region
        if ((Abs(offset.x) < headOffsetY) || (Abs(offset.y) < headOffsetY))
        {
            if(class'MenuChoice_BalanceEtc'.static.IsEnabled()) {
                // do 1.7x damage instead of the 2x damage in DeusExPlayer.uc::TakeDamage()
                return Damage * 0.85;
            }
        }
    }
    else if (offset.z < 0.0)        // legs
    {
    }
    else                            // arms and torso
    {
        if (offset.y > armOffset)
        {
            // right arm
        }
        else if (offset.y < -armOffset)
        {
            // left arm
        }
        else if(class'MenuChoice_BalanceEtc'.static.IsEnabled())
        {
            // and finally, the torso! do 1.4x damage instead of the 2x damage in DeusExPlayer.uc::TakeDamage()
            return Damage * 0.7;
        }
    }

    return Damage;
}

function float ReduceEnviroDamage(float damage, name damageType)
{
    local float skillLevel, augLevel;
    local HazmatSuit suit;

    augLevel = -1;

    if (damageType != 'TearGas' && damageType != 'PoisonGas' && damageType != 'Radiation'
        && damageType != 'HalonGas' && damageType != 'PoisonEffect' && damageType != 'Poison'
        && damageType != 'Flamed' && damageType != 'Burned' && damageType != 'Shocked' ) {
            return damage;
    }

    if (AugmentationSystem != None)
        augLevel = AugmentationSystem.GetAugLevelValue(class'AugEnviro');

    if (augLevel >= 0.0)
        damage *= augLevel;

    // get rid of poison if we're maxed out
    if (damage ~= 0.0)
    {
        StopPoison();
        drugEffectTimer -= 4;	// stop the drunk effect
        if (drugEffectTimer < 0)
            drugEffectTimer = 0;
    }

    if(damageType == 'PoisonEffect' || damageType == 'Poison') {
        return damage;
    }

    skillLevel = SkillSystem.GetSkillLevelValue(class'SkillEnviro');
    skillLevel = FClamp(skillLevel, 0, 1.1);

    if (UsingChargedPickup(class'HazMatSuit'))
    {
        damage *= 0.75 * skillLevel;
        if (UsingBiomod()){
            //Biomod makes hazmat charge only decrease when protecting against damage
            foreach AllActors(class'HazMatSuit',suit) {
                if (suit.owner==Self && suit.bActive) {
                    suit.charge -= damage * skillLevel; //Calculation yoinked from Biomod/DeusEx.u
                }
            }

        }
    }
    else if(class'MenuChoice_BalanceSkills'.static.IsEnabled())// passive enviro skill still gives some damage reduction
    {
        damage *= 1.1 * skillLevel + 0.3;
    }

    return damage;
}

function float ArmorReduceDamage(float damage)
{
    local float skillLevel;
    local BallisticArmor ba;

    // go through the actor list looking for owned BallisticArmor
    // since they aren't in the inventory anymore after they are used
    if (UsingChargedPickup(class'BallisticArmor'))
    {
        skillLevel = SkillSystem.GetSkillLevelValue(class'SkillEnviro');
        if(skillLevel < 0)
            skillLevel = 0;

        if (UsingBiomod()){
            //Biomod makes ballistic armour charge only decrease when protecting against damage
            foreach AllActors(class'BallisticArmor',ba) {
                if (ba.owner==Self && ba.bActive) {
                    ba.charge -= damage * 2 * skillLevel; //Calculation yoinked from Biomod/DeusEx.u
                    break;
                }
            }
        }
        return damage * 0.5 * skillLevel;
    }
    return damage;
}

function bool UsingBiomod()
{
    local string PathsString;

    PathsString = ConsoleCommand( "GET LaunchSystem Paths" );

    return InStr(PathsString,"Biomod")!=-1;
}

function bool UsingShifter()
{
    local string PathsString;

    PathsString = ConsoleCommand( "GET LaunchSystem Paths" );

    return InStr(PathsString,"Shifter")!=-1;
}

function CatchFire( Pawn burner )
{
    local bool doSetTimer;
    if (bOnFire==false && Region.Zone.bWaterZone==false)
        doSetTimer = true;

    Super.CatchFire(burner);

    // set the burn timer, tick the burn every 4 seconds instead of 1 so that the player can actually survive it
    if(doSetTimer)
        SetTimer(4.0, True);
}

simulated function DrugEffects(float deltaTime)
{
    local float olddrugEffectTimer;
    local DeusExRootWindow root;
    local bool wasActive;

    // set a cap on the effect strength separately from the duration
    olddrugEffectTimer = drugEffectTimer;
    drugEffectTimer = FMin( drugEffectTimer, 120.0 );
    Super.DrugEffects(deltaTime);

    // calculate duration myself
    drugEffectTimer = FMin(olddrugEffectTimer, 120.0 );
    wasActive = (drugEffectTimer>0);
    drugEffectTimer -= deltaTime * 1.5;
    if (drugEffectTimer < 0) {
        drugEffectTimer = 0;
        if (wasActive){
            //This theoretically fixes the issue where the game stays zoomed in
            //after being drunk until you switch what's in your hands
            root = DeusExRootWindow(rootWindow);
            if ((root != None) && (root.hud != None))
            {
                if (root.hud.background != None)
                {
                    root.hud.SetBackground(None);
                    root.hud.SetBackgroundStyle(DSTY_Normal);
                    DesiredFOV = Default.DesiredFOV;
                }
            }
        }
    }
}


// ----------------------------------------------------------------------
// HealPlayer()
// ----------------------------------------------------------------------

//"Source" is added by Revision, for tracking healing from different sources (for cheevos? so we can mostly ignore for now)
function int HealPlayer(int baseHealPoints, optional Bool bUseMedicineSkill, optional String source)
{
    local int adjustedHealAmount;
    local bool fixLegs;

    //Alcohol fixes broken legs, as long as it isn't zero rando
    if (source=="Forty" || source=="Liquor" || source=="Wine") fixLegs = class'MenuChoice_BalanceItems'.static.IsEnabled();

    adjustedHealAmount = _HealPlayer(baseHealPoints, bUseMedicineSkill, fixLegs);

    if (adjustedHealAmount == 1)
        ClientMessage(Sprintf(HealedPointLabel, adjustedHealAmount));
    else if(adjustedHealAmount != 1)// we want messages for healing 0 so you know it could've healed you
        ClientMessage(Sprintf(HealedPointsLabel, adjustedHealAmount));

    return adjustedHealAmount;
}

function int _HealPlayer(int baseHealPoints, optional Bool bUseMedicineSkill, optional bool bFixLegs)
{
    local float mult;
    local int adjustedHealAmount, aha2, tempaha;
    local int origHealAmount;
    local float dividedHealAmount;

    if (bUseMedicineSkill)
        adjustedHealAmount = CalculateSkillHealAmount(baseHealPoints);
    else
        adjustedHealAmount = baseHealPoints;

    origHealAmount = adjustedHealAmount;

    if (adjustedHealAmount > 0)
    {
        if (bUseMedicineSkill)
            PlaySound(sound'MedicalHiss', SLOT_None,,, 256);

        // Heal by 3 regions via multiplayer game
        if (( Level.NetMode == NM_DedicatedServer ) || ( Level.NetMode == NM_ListenServer ))
        {
            // DEUS_EX AMSD If legs broken, heal them a little bit first
            if (HealthLegLeft == 0)
            {
                aha2 = adjustedHealAmount;
                if (aha2 >= 5)
                    aha2 = 5;
                tempaha = aha2;
                adjustedHealAmount = adjustedHealAmount - aha2;
                HealPart(HealthLegLeft, aha2);
                HealPart(HealthLegRight,tempaha);
                mpMsgServerFlags = mpMsgServerFlags & (~MPSERVERFLAG_LostLegs);
            }
            HealPart(HealthHead, adjustedHealAmount);

            if ( adjustedHealAmount > 0 )
            {
                aha2 = adjustedHealAmount;
                HealPart(HealthTorso, aha2);
                aha2 = adjustedHealAmount;
                HealPart(HealthArmRight,aha2);
                HealPart(HealthArmLeft, adjustedHealAmount);
            }
            if ( adjustedHealAmount > 0 )
            {
                aha2 = adjustedHealAmount;
                HealPart(HealthLegRight, aha2);
                HealPart(HealthLegLeft, adjustedHealAmount);
            }
        }
        else
        {
            // balanced healing, issue #406
            if( adjustedHealAmount >= 18 ) {
                aha2 = adjustedHealAmount / 10;// use most of it for the balanced heal, the rest for normal healing behavior
                aha2 = Max(aha2, 3);
                _HealPart(HealthHead, adjustedHealAmount, aha2);
                _HealPart(HealthTorso, adjustedHealAmount, aha2);
                _HealPart(HealthLegRight, adjustedHealAmount, aha2);
                _HealPart(HealthLegLeft, adjustedHealAmount, aha2);
                _HealPart(HealthArmRight, adjustedHealAmount, aha2);
                _HealPart(HealthArmLeft, adjustedHealAmount, aha2);
            }
            else if( bUseMedicineSkill || bFixLegs ) {
                HealBrokenPart(HealthLegRight, adjustedHealAmount);
                HealBrokenPart(HealthLegLeft, adjustedHealAmount);
            }
            HealPart(HealthHead, adjustedHealAmount);
            HealPart(HealthTorso, adjustedHealAmount);
            HealPart(HealthLegRight, adjustedHealAmount);
            HealPart(HealthLegLeft, adjustedHealAmount);
            HealPart(HealthArmRight, adjustedHealAmount);
            HealPart(HealthArmLeft, adjustedHealAmount);
        }

        GenerateTotalHealth();

        adjustedHealAmount = origHealAmount - adjustedHealAmount;
    }

    return adjustedHealAmount;
}

function int HealBrokenPart(out int points, out int amt)
{
    local int heal;
    heal = 1;
    if( points > 0 || amt < heal ) return 0;
    amt -= heal;
    return _HealPart(points, heal, 1);
}

function int _HealPart(out int points, out int amt, int max)
{
    local int spill, healed;

    max = Min(amt, max);

    points += max;
    spill = points - default.HealthTorso;
    if (spill > 0)
        points = default.HealthTorso;
    else
        spill = 0;

    healed = max - spill;
    amt -= healed;
    return healed;
}

function HealPart(out int points, out int amt)
{
    // override the original function, we can't change the function signature when overriding
    _HealPart(points, amt, amt);
}

function PickupNanoKey(NanoKey newKey)
{
    local string msg;
    if (newKey.keyID==''){
        msg = "You just picked up a key ("$newKey$") without a key ID ("$newKey.Description$")!  Report this to the devs, we're looking for this!  Where did you find me?";
        if (!class'DXRVersion'.static.VersionIsStable()){
            ClientMessage(msg);
        } else {
            log(msg);
        }
    }
    Super.PickupNanoKey(newKey);
}



event PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
    local CCResidentEvilCam reCam;

    reCam = CCResidentEvilCam(ViewTarget);

    if (reCam!=None){
        CameraRotation = reCam.Rotation;
        CameraLocation = reCam.Location;
        return;
    } else {
        Super.PlayerCalcView(ViewActor,CameraLocation,CameraRotation);
        if (bDoomMode){
            CameraRotation.Pitch=0;
            ViewRotation.Pitch=0;
        }
    }
}

function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
    local vector View,HitLocation,HitNormal;
    local float ViewDist;

    Dist = Dist/1.25; //Bring the camera in a bit closer than normal

    CameraRotation = ViewRotation;
    CameraLocation.Z+=BaseEyeHeight; //Adjust camera center to eye height
    View = vect(1,-0.2,0) >> CameraRotation; //Slightly offset the view to the right (so it's over the shoulder)
    if( Trace( HitLocation, HitNormal, CameraLocation - (Dist + 30) * vector(CameraRotation), CameraLocation ) != None )
        ViewDist = FMin( (CameraLocation - HitLocation) Dot View, Dist );
    else
        ViewDist = Dist;
    CameraLocation -= (ViewDist - 30) * View;
}


function HighlightCenterObject()
{
    if (IsInState('Dying'))
        return;

    HighlightCenterObjectMain();
    HighlightCenterObjectLaser();
}

function HighlightCenterObjectMain()
{
    local Actor target, t;
    local int fails;
    local float dist, dist2;

    target = HighlightCenterObjectRay(vect(0,0,0), dist);

    if(LevelInfo(target) != None) target = None;

    if(target != None && Brush(target) == None && class'MenuChoice_FixGlitches'.default.enabled) {
        t = HighlightCenterObjectRay(vect(0,-0.2,1.5), dist2);
        fails += int(t!=target && dist2 < dist && (LevelInfo(t)!=None || Brush(t)!=None));

        t = HighlightCenterObjectRay(vect(0,-1,-1), dist2);
        fails += int(t!=target && dist2 < dist && (LevelInfo(t)!=None || Brush(t)!=None));

        t = HighlightCenterObjectRay(vect(0,1.5,-0.5), dist2);
        fails += int(t!=target && dist2 < dist && (LevelInfo(t)!=None || Brush(t)!=None));

        if(fails > 1) target = None;
    }

    // DXRando: if we already have a frob target, and the player looks away such as that no item is being
    // traced, we still wait for the full 100ms vanilla duration before clearing the frob
    // target.
    //
    // note that this means we don't wait for the full 100ms vanilla duration if the player is
    // rapidly changing frob target.
    if (FrobTime < 0.1 && FrobTarget != None && target == None && !FrobTarget.bDeleteMe)
    {
        return;
    }

    FrobTarget = target;
    FrobTime = 0; // reset our frob timer
}

function Actor HighlightCenterObjectRay(vector offset, out float smallestTargetDist)
{
    local Actor target, smallestTarget;
    local DeathMarker dm;
    local Vector HitLoc, HitNormal, StartTrace, EndTrace;
    local float minSize;
    local bool bFirstTarget, biomodDroneFrob;


    // DXRando: we do the trace every frame, unlike the vanilla behaviour of doing it every 100ms
    biomodDroneFrob=false;
    if (UsingBiomod() && bSpyDroneActive){ //Biomod allows frobbing some objects with spy drone
        biomodDroneFrob=true;
    }
    if (biomodDroneFrob){
        StartTrace = aDrone.Location + (offset >> ViewRotation);
        EndTrace = aDrone.Location + (Vector(ViewRotation) * MaxFrobDistance);
    } else {
        // figure out how far ahead we should trace
        StartTrace = Location + (offset >> ViewRotation);
        EndTrace = StartTrace + (Vector(ViewRotation) * MaxFrobDistance);

        // adjust for the eye height
        StartTrace.Z += BaseEyeHeight;
        EndTrace.Z += BaseEyeHeight;
    }

    smallestTarget = None;
    minSize = 99999;
    smallestTargetDist = 99999;
    bFirstTarget = True;

    // find the object that we are looking at
    // make sure we don't select the object that we're carrying
    // use the last traced object as the target...this will handle
    // smaller items under larger items for example
    // ScriptedPawns always have precedence, though
    foreach TraceActors(class'Actor', target, HitLoc, HitNormal, EndTrace, StartTrace)
    {
        if (biomodDroneFrob){
            if (IsFrobbable(target) && (target != CarriedDecoration))
            {
                if (!(target.IsA('Computers') && spyDroneLevel >= 3) && !((target.IsA('Button1') || target.IsA('Switch1') || target.IsA('Switch2') || target.IsA('LightSwitch')) && spyDroneLevel >= 2) && !(target.IsA('InformationDevices') && spyDroneLevel >= 1))
                    break;
                else if (target.CollisionRadius < minSize)
                {
                    minSize = target.CollisionRadius;
                    smallestTarget = target;
                    bFirstTarget = False;
                }
            }
        } else {
            if(DeathMarker(target) != None) {
                if(dm == None && target.CollisionRadius < minSize) {
                    dm = DeathMarker(target);
                    if(bFirstTarget) smallestTargetDist = VSize(Location-HitLoc);
                }
                continue;
            }

            if (UsingBiomod() || UsingShifter()){
                //With Biomod or Shifter, you can give weapons to certain characters, like Gunther, Gilbert, and Miguel
                ShowGiveNPCWeaponDisplay();
            }

            if (IsFrobbable(target) && (target != CarriedDecoration))
            {
                if (target.IsA('ScriptedPawn'))
                {
                    smallestTarget = target;
                    smallestTargetDist = VSize(Location-HitLoc);
                    break;
                }
                else if (target.IsA('Mover'))
                {
                    if(bFirstTarget) {
                        smallestTarget = target;
                        smallestTargetDist = VSize(Location-HitLoc);
                    }
                    break;
                }
                else if (target.CollisionRadius < minSize)
                {
                    minSize = target.CollisionRadius;
                    smallestTarget = target;
                    bFirstTarget = False;
                    smallestTargetDist = VSize(Location-HitLoc);
                }
            }
            else if(LevelInfo(target) != None || Brush(target) != None) {
                if(bFirstTarget && dm==None) {
                    smallestTargetDist = VSize(Location-HitLoc);
                    smallestTarget = Level;
                }
                minSize = -1; // don't allow any actors after this, but do allow Movers
            }
        }
    }

    if(smallestTarget == None || LevelInfo(target) != None) {
        return dm;
    }

    return smallestTarget;
}

function HighlightCenterObjectLaser()
{
    local Vector loc;

    //Activate the aim laser any time you aren't seeing through your eyes
    if (class'DXRAimLaserEmitter'.static.AimLaserShouldBeOn(self)){
        if (aimLaser==None){
            aimLaser = Spawn(class'DXRAimLaserEmitter', Self, , Location, Pawn(Owner).ViewRotation);
            if (aimLaser == None) {
                ClientMessage("Failed to spawn aim laser?");
            }
        }

        loc = Location;
        loc.Z+=BaseEyeHeight;
        loc = loc + vector(ViewRotation) * (CollisionRadius/2);
        aimLaser.SetLocation(loc);
        aimLaser.SetRotation(ViewRotation);
        aimLaser.proxy.DistanceFromPlayer=0; //Make sure the laser doesn't get frozen

        aimLaser.TurnOn();

    } else {
        if (aimLaser!=None){
            aimLaser.TurnOff();
        }
    }
}

//Biomod and Shifter only - shows text when you can give a weapon to an NPC (Gunther, Gilbert, Miguel)
//Duplicated from RevJCDentonMale::HighlightCenterObject
function ShowGiveNPCWeaponDisplay()
{
    local DeusExRootWindow root;
    root = DeusExRootWindow(rootWindow);

    if(ScriptedPawn(FrobTarget) != None)
    {
        if(ScriptedPawn(FrobTarget).bCanGiveWeapon && ScriptedPawn(FrobTarget).CheckPawnAllianceType(Self) != ALLIANCE_Hostile)
        {
            if(VSize(FrobTarget.Location - Location) <= 64 &&
               root != None &&
               DeusExWeapon(inHand) != None)
            {
                if(!root.hud.startDisplay.bTickEnabled)
                {
                    root.hud.startDisplay.message = "";
                    root.hud.startDisplay.charIndex = 0;
                    root.hud.startDisplay.winText.SetText("");
                    root.hud.startDisplay.winTextShadow.SetText("");

                    if(DeusExWeapon(inHand) != None)
                        root.hud.startDisplay.AddMessage(GivePawnString @ ScriptedPawn(FrobTarget).FamiliarName @ TheString @ inHand.ItemName $ ".");

                    if(root.hud.startDisplay.message != "")
                        root.hud.startDisplay.StartMessage();
                }

                root.hud.startDisplay.DisplayTime = 0.15;
            }
        }
    }
}

event WalkTexture( Texture Texture, vector StepLocation, vector StepNormal )
{
    local DolphinJumpTrigger dolphin;
    if ( Texture!=None && Texture.Outer!=None && Texture.Outer.Name=='Ladder' ) {
        if(!bOnLadder) {
            foreach AllActors(class'DolphinJumpTrigger', dolphin) {
                dolphin.SelfDestruct();
            }
        }
        bOnLadder = True;
    }
    else
        bOnLadder = False;
}

event HeadZoneChange(ZoneInfo newHeadZone)
{
    if (HeadRegion.Zone.bWaterZone && !newHeadZone.bWaterZone)
    {
        class'DolphinJumpTrigger'.static.CreateDolphin(self);
    }
    Super.HeadZoneChange(newHeadZone);
}

function Landed(vector HitNormal)
{
    local DolphinJumpTrigger dolphin;
    foreach AllActors(class'DolphinJumpTrigger', dolphin) {
        dolphin.SelfDestruct();
    }
    Super.Landed(HitNormal);
}

function bool CanInstantLeftClick(DeusExPickup item)
{
    if (inHand!=None) return false;

    if (item==None) return false;
    if (item.bActivatable==False) return false;
    if (item.GetStateName()=='Activated') return false;
    if (item.Owner == self) return false;// we already own the item?
    if (item.bDeleteMe) return false;// just in case!

    if (Binoculars(item)!=None) return false; //Unzooming requires left clicking the binocs again
    if (class'MenuChoice_BalanceItems'.static.IsDisabled() && ChargedPickup(item) != None) return false;
    return true;
}

exec function ParseLeftClick()
{
    local DeusExPickup item;

    Super.ParseLeftClick();
    item = DeusExPickup(FrobTarget);
    if (item != None && CanInstantLeftClick(item))
    {
        InstantlyUseItem(item);
        FrobTarget = None;
    }
}

function InstantlyUseItem(DeusExPickup item)
{
    local Actor A;
    local DeusExPickup p;
    local int i;

    if(item == None) return;

    //TODO: Check loadout for ban

    //Only consume one of the things if it's in a stack.
    //Spawn an individual one to split it from the stack before using it.
    if (item.NumCopies>1){
        p = Spawn(item.Class,,,item.Location,item.Rotation);
        p.NumCopies=1;
        item.NumCopies--;
        InstantlyUseItem(p);
        return;
    }

    foreach item.BasedActors(class'Actor', A)
        A.SetBase(None);
    // So that any effects get applied to you
    item.SetOwner(self);
    item.SetBase(self);
    // add to the player's inventory, so ChargedPickups travel across maps
    item.BecomeItem();
    item.bDisplayableInv = false;
    item.Inventory = Inventory;
    Inventory = item;
    if(FireExtinguisher(item) != None) {
        // this was buggy with multiple, but it doesn't make sense and wouldn't be useful to use multiple at once anyways
        // this shouldn't get hit anymore, but still do this, just in case
        item.NumCopies = 1;
    }

    //In theory this should only be one, but just in case we slipped through the case above...
    for(i=item.NumCopies; i > 0; i--) {
        item.Activate();
    }
}

//Similar duplicated logic from DXRVanilla/Weapon.uc::HandlePickupQuery
function bool CheckForRemainingWeaponAmmo(#var(DeusExPrefix)Weapon W)
{
    local class<Ammo> defAmmoClass;
    local Ammo defAmmo,newAmmo;
    local int ammoToAdd,ammoRemaining;

    if (W==None) return True; //Don't know what you're looting, but it's apparently not a weapon

    if (!( (w.bWeaponStay && (Level.NetMode == NM_Standalone)) && (!w.bHeldItem || w.bTossedOut)))
    {
        if ( w.AmmoNames[0] == None ){
            defAmmoClass = w.AmmoName;
        }else{
            defAmmoClass = w.AmmoNames[0];
        }
        defAmmo = Ammo(FindInventoryType(defAmmoClass));
        if(defAmmo!=None){
            ammoToAdd = w.PickUpAmmoCount;
            ammoRemaining=0;
            if ((ammoToAdd + defAmmo.AmmoAmount) > defAmmo.MaxAmmo){
                ammoRemaining = (ammoToAdd + defAmmo.AmmoAmount) - defAmmo.MaxAmmo;
                ammoToAdd = ammoToAdd - ammoRemaining;
            }


            w.PickUpAmmoCount = ammoToAdd;
            if (ammoRemaining>0){
                if(defAmmo.Default.Mesh!=LodMesh'DeusExItems.TestBox' && defAmmo.Default.PickupViewMesh!=LodMesh'DeusExItems.TestBox'){
                    //Weapons with normal ammo that exists
                    newAmmo = Spawn(defAmmoClass,,,w.Location,w.Rotation);
                    newAmmo.ammoAmount = ammoRemaining;
                    newAmmo.Velocity = Velocity + VRand() * 160;
                    return true;
                } else {
                    w.PickUpAmmoCount = ammoRemaining;
                    defAmmo.AddAmmo(ammoToAdd);
                    if (ammoToAdd>0){
                        ClientMessage("Took "$ammoToAdd$" "$defAmmo.ItemName,, true);
                    } else {
                        ClientMessage(TooMuchAmmo);
                    }
                    return false;
                }
            }
        }
    }
    return true;
}

function bool CheckForAmmoToLeaveBehind(Ammo thisAmmo)
{
    local Ammo ownedAmmo;
    local int ammoToAdd,ammoRemaining;

    if (thisAmmo==None) return True; //I don't know how this would happen
    if (thisAmmo.AmmoAmount<=0) return True; //Ammo is empty, so you can definitely handle it

    ownedAmmo = Ammo(FindInventoryType(thisAmmo.Class));
    if (ownedAmmo!=None){
        ammoToAdd = thisAmmo.AmmoAmount;
        ammoRemaining=0;
        if ((ammoToAdd + ownedAmmo.AmmoAmount) > ownedAmmo.MaxAmmo){
            ammoRemaining = (ammoToAdd + ownedAmmo.AmmoAmount) - ownedAmmo.MaxAmmo;
            ammoToAdd = ammoToAdd - ammoRemaining;
        }

        if (ammoRemaining>0){
            thisAmmo.ammoAmount = ammoRemaining;
            ownedAmmo.AddAmmo(ammoToAdd);
            if (ammoToAdd>0){
                ClientMessage("Took "$ammoToAdd$" "$thisAmmo.ItemName,, true);
            } else {
                ClientMessage(TooMuchAmmo);
            }
            return False; //What ammo can be taken has been taken, but you "can't" pick up the actual item
        }
    }

    return True;
}


function bool HandleItemPickup(Actor FrobTarget, optional bool bSearchOnly)
{
    local bool bCanPickup;
    local #var(DeusExPrefix)Weapon weap,ownedWeapon;
    local int ammoAvail,ammoToAdd,ammoRemaining;
    local class<Ammo> defAmmoClass;
    local #var(DeusExPrefix)Ammo ownAmmo,ammoItem;
    local bool isThrown, isMelee;
    local #var(DeusExPrefix)Pickup pickup,ownedPickup;
    local #var(prefix)WeaponMod mod;

    //TODO: Loadout logic from vanilla not ported over (yet)

    //Try to apply the mod being picked up to the currently held weapon
    if (class'MenuChoice_AutoWeaponMods'.default.enabled){
        mod = #var(prefix)WeaponMod(FrobTarget);
        weap = #var(DeusExPrefix)Weapon(inHand);

        //Revision hits this from looting a carcass, but we don't want to auto apply in that case
        if (mod!=None && weap!=None && DeusExCarcass(mod.Owner)==None){
            if (mod.CanUpgradeWeapon(weap)){
                mod.ApplyMod(weap);
                ClientMessage(mod.ItemName$" applied to "$weap.ItemName,, true);
                if (mod.IsA('WeaponModLaser') && class'MenuChoice_AutoLaser'.default.enabled){
                    weap.LaserOn();
                }
                mod.DestroyMod();
                return true;
            }
        }
    }

    ammoItem = #var(DeusExPrefix)Ammo(FrobTarget);
    if (ammoItem!=None){
        //Ammo not full, but not necessarily able to take *all* the ammo, so check
        if (False == CheckForAmmoToLeaveBehind(ammoItem)){
            return false;
        }
    }

    weap = #var(DeusExPrefix)Weapon(FrobTarget);
    if (weap!=None && weap.PickUpAmmoCount!=0){
        if (False==CheckForRemainingWeaponAmmo(weap)){
            return false;
        }
    }

    bCanPickup = Super.HandleItemPickup(FrobTarget, bSearchOnly);

    //Ammo Looting
    if (bCanPickup==False && weap!=None && weap.PickUpAmmoCount!=0){
        ownedWeapon=#var(DeusExPrefix)Weapon(FindInventoryType(FrobTarget.Class));
        //You can't pick up the weapon, but let's yoink the ammo
        if (ownedWeapon==None){
            ammoAvail = weap.PickUpAmmoCount;
            if (weap.AmmoNames[0]==None){
                defAmmoClass=weap.AmmoName;
            } else {
                defAmmoClass=weap.AmmoNames[0];
            }

            isThrown = ClassIsChildOf(weap.ProjectileClass,class'ThrownProjectile') || weap.ProjectileClass==class'Shuriken';
            isMelee = weap.bHandToHand; //Biomod allows you to throw various melee weapons (knives, crowbars, etc)

            if (defAmmoClass!=class'#var(prefix)AmmoNone' && !isThrown && !isMelee){
                ownAmmo = #var(DeusExPrefix)Ammo(FindInventoryType(defAmmoClass));

                if (ownAmmo==None){
                    ownAmmo = #var(DeusExPrefix)Ammo(Spawn(defAmmoClass));
                    AddInventory(ownAmmo);
                    ownAmmo.BecomeItem();
                    ownAmmo.AmmoAmount=0;
                    ownAmmo.GotoState('Idle2');
                }

                ammoRemaining=0;
                ammoToAdd = ammoAvail;
                if (ownAmmo.AmmoAmount+ammoAvail > ownAmmo.MaxAmmo) {
                    ammoToAdd = ownAmmo.MaxAmmo - ownAmmo.AmmoAmount;
                    ammoRemaining = ammoAvail - ammoToAdd;
                }

                ownAmmo.AddAmmo(ammoToAdd);
                weap.PickUpAmmoCount=ammoRemaining;
                ClientMessage("Took "$ammoToAdd$" "$ownAmmo.ItemName$" from "$weap.ItemName,, true);
                UpdateBeltText(weap);
            }
        }
    }

    //Looting partial stacks of items (eg 1 out of 3 in a stack of multitools)
    pickup = #var(DeusExPrefix)Pickup(FrobTarget);
    if (pickup!=None && pickup.Owner!=Self && pickup.maxCopies>1){
        //Pickup failed
        ownedPickup=#var(DeusExPrefix)Pickup(FindInventoryType(FrobTarget.Class));
        if (ownedPickup!=None && (ownedPickup.NumCopies+pickup.NumCopies)>ownedPickup.maxCopies){
            ammoToAdd=ownedPickup.maxCopies - ownedPickup.NumCopies;
            if (ammoToAdd!=0){
                pickup.NumCopies = (ownedPickup.NumCopies+pickup.NumCopies)-ownedPickup.maxCopies;
                ownedPickup.NumCopies = ownedPickup.maxCopies;
                UpdateBeltText(ownedPickup);
                ClientMessage("Picked up "$ammoToAdd$" of the "$pickup.ItemName,, true);
            }
        }

    }

    return bCanPickup;
}

function float GetCurrentGroundSpeed()
{
    local float augValue, speed;

    // Remove this later and find who's causing this to Access None MB
    if ( AugmentationSystem == None )
        return 0;

    augValue = AugmentationSystem.GetAugLevelValue(class'AugSpeed');
    augValue = FMax(augValue, AugmentationSystem.GetAugLevelValue(class'AugNinja'));
    augValue = FMax(augValue, AugmentationSystem.GetAugLevelValue(class'AugOnlySpeed'));

    if (augValue == -1.0)
        augValue = 1.0;

    if ( Level.NetMode != NM_Standalone )
        speed = Self.mpGroundSpeed * augValue;
    else
        speed = Default.GroundSpeed * augValue;

    if (UsingBiomod()){
        //Swimming is athletics in Biomod, which modifies movespeed
        if(!bIsCrouching && !bForceDuck)
        {
            augValue = SkillSystem.getSkillLevel(class'SkillSwimming');

            switch(augValue)
            {
                case 1.0:
                    augValue = 1.0;
                    break;

                case 2.0:
                    augValue = 1.1;
                    break;

                case 3.0:
                    augValue = 1.2;
                    break;

                default:
                    augValue = 0.8;
                    break;
            }

            speed *= augValue;
        }
    }
    if (UsingBiomod() || UsingShifter()){
        if(drugEffectTimer < 0) //(FindInventoryType(Class'DeusEx.ZymeCharged') != None)
            speed += Default.GroundSpeed * 0.2;
    }


    return speed;
}

function bool ShouldAddToBelt(inventory NewItem)
{
    local DeusExRootWindow root;
    local #var(prefix)HUDObjectBelt belt;
    local Inventory beltItem;
    local int i;

    //Belt is locked, don't add anything
    if (!class'MenuChoice_LockBelt'.static.AddToBelt(NewItem)) return False;

    root = DeusExRootWindow(rootWindow);
    belt = root.hud.belt;

    //Don't add an item to the belt if you have another one
    //of the same item on the belt already
    for (i=0;i<ArrayCount(belt.objects);i++){
        beltItem = belt.objects[i].GetItem();
        if (beltItem==None) continue;
        if (beltItem==NewItem) continue; //The new item will have already been added to the belt by the time we get here, so ignore ourself
        if (beltItem.class==NewItem.class) return False; //There's another of the same class already on the belt, get outta here!
    }

    return True;
}

function bool AddInventory( inventory NewItem )
{
    local bool retval;
    local DeusExRootWindow root;
/*
    if( loadout == None ) loadout = DXRLoadouts(DXRFindModule(class'DXRLoadouts'));
    if ( loadout != None && loadout.ban(self, NewItem) ) {
        NewItem.Destroy();
        return true;
    }
*/
    retval = Super.AddInventory(NewItem);

    if (NewItem.bInObjectBelt){ //Item was added to the belt automatically
        if (!ShouldAddToBelt(NewItem)) { //Do we actually want it on the belt?
            root = DeusExRootWindow(rootWindow);
            if (root!=None){
                root.hud.belt.RemoveObjectFromBelt(NewItem); //Get that thing off my belt!
            }
        }
    }

    return retval;
}

function bool IsThemeAdded(Class<ColorTheme> themeClass)
{
    local ColorTheme curTheme;
    local ColorTheme prevTheme;
    local Bool bDeleted;

    bDeleted    = False;
    curTheme = ThemeManager.FirstColorTheme;

    while(curTheme != None)
    {
        if ((curTheme.GetThemeName() == themeClass.default.themeName) && (curTheme.IsSystemTheme() == themeClass.default.bSystemTheme) && curTheme.themeType == themeClass.default.themeType)
        {
            return True;
        }

        curTheme = curTheme.next;
    }
    return False;

}

function AddColorTheme(Class<ColorTheme> themeClass)
{
    if(IsThemeAdded(themeClass)==False){
        ThemeManager.AddTheme(themeClass);
    }
}

function CreateColorThemeManager()
{
    local ColorTheme theme;
    Super.CreateColorThemeManager();

    AddColorTheme(Class'ColorThemeHUD_HotDogStand');
    AddColorTheme(Class'ColorThemeMenu_HotDogStand');
    AddColorTheme(Class'ColorThemeHUD_Black');
    AddColorTheme(Class'ColorThemeMenu_Black');
    AddColorTheme(Class'ColorThemeHUD_Rando');
    AddColorTheme(Class'ColorThemeMenu_Rando');
    AddColorTheme(Class'ColorThemeHUD_Swirl');
    AddColorTheme(Class'ColorThemeMenu_Swirl');
    AddColorTheme(Class'ColorThemeHUD_Health');
    AddColorTheme(Class'ColorThemeMenu_Health');
}

function UpdateRotation(float DeltaTime, float maxPitch)
{
    local DataStorage datastorage;
    local int rollAmount;
    datastorage = class'DataStorage'.static.GetObjFromPlayer(self);
    if(datastorage != None) rollAmount = int(datastorage.GetConfigKey('cc_cameraRoll'));

    if(rollAmount == 0) {
        Super.UpdateRotation(DeltaTime,maxPitch);
        return;
    }

    //Track and handle shake rotation as though we are always right-ways up
    //Carry the Yaw over, since the shake doesn't adjust that, so it resets you
    //to Yaw 0 when a roll starts otherwise (Issue #608)
    ShakeRotator.Yaw = ViewRotation.Yaw;
    ViewRotation = ShakeRotator;
    Super.UpdateRotation(DeltaTime,maxPitch);
    ShakeRotator = ViewRotation;

    //Apply any roll after figuring out (and storing) the current shake state
    ViewRotation.Roll += rollAmount;
}

exec function ToggleScope()
{
    local DeusExWeapon W;
    local Inventory inv;

    if (RestrictInput())
        return;

    W = DeusExWeapon(Weapon);
    if (W != None)
    {
        W.ScopeToggle();
    }
    else
    {
        for(inv = Inventory; inv != None; inv = inv.Inventory)
        {
            if ( Binoculars(inv) != None )
            {
                PutInHand(inv);
                inv.Activate();
                break;
            }
        }
    }
}

exec function PlayerLoc()
{
    ClientMessage("Player location: (" $ Location.x $ ", " $ Location.y $ ", " $ Location.z $ ")");
}

exec function PlayerRot()
{
    ClientMessage("Player rotation: (" $ Rotation.pitch $ ", " $ Rotation.yaw $ ", " $ Rotation.roll $ ")");
}
