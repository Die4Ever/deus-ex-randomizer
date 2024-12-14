class BalancePlayer injects Human;

var travel bool bZeroRando, bReducedRando, bCrowdControl;

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
    local float augLevel;

    if(Level.LevelAction != LEVACT_None) return;

    if(damageType == 'NanoVirus') {
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
    Super.TakeDamage(Damage, instigatedBy, hitlocation, momentum, damageType);
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
            if(!bZeroRando) {
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
        else if(!bZeroRando)
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
    }
    else // passive enviro skill still gives some damage reduction
    {
        damage *= 1.1 * skillLevel + 0.3;
    }

    return damage;
}

function float ArmorReduceDamage(float damage)
{
    local float skillLevel;

    // go through the actor list looking for owned BallisticArmor
    // since they aren't in the inventory anymore after they are used
    if (UsingChargedPickup(class'BallisticArmor'))
    {
        skillLevel = SkillSystem.GetSkillLevelValue(class'SkillEnviro');
        if(skillLevel < 0)
            skillLevel = 0;
        return damage * 0.5 * skillLevel;
    }
    return damage;
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
    if ((damageType == 'Shot') || (damageType == 'AutoShot') ||
        damageType == 'Flamed' || damageType == 'Burned')
    {
        newDamage *= CombatDifficulty;
        oldDamage *= CombatDifficulty;
    }
    else if (damageType != 'fell' && damageType != 'Drowned') {
        damageMult = CombatDifficultyMultEnviro();
        newDamage *= damageMult;
        oldDamage *= damageMult;
    }

    if(frand() < (newDamage%1.0)) {// DXRando: random rounding, 1.9 is more likely to round up than 1.1 is
        newDamage += 0.999;
        oldDamage += 0.999;
    }

    adjustedDamage = Int(newDamage);// adjustedDamage is our out param

    if(damageType == 'TearGas' && adjustedDamage*2 >= HealthTorso) {
        // TearGas can't kill you
        adjustedDamage = 0;
        HealthTorso = 1;
    }

    return bReduced;
}

function float CombatDifficultyMultEnviro()
{
    return (CombatDifficulty*0.25) + 0.75;// 25% wet / 75% dry
}

function float GetDamageMultiplier()
{
    local DataStorage datastorage;

    if (!bCrowdControl) return 0;

    datastorage = class'DataStorage'.static.GetObjFromPlayer(self);
    return float(datastorage.GetConfigKey('cc_damageMult'));
}

function bool WineBulletsActive()
{
    local DataStorage datastorage;

    if (!bCrowdControl) return False;

    datastorage = class'DataStorage'.static.GetObjFromPlayer(self);
    return bool(datastorage.GetConfigKey('cc_WineBullets'));
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

function int HealPlayer(int baseHealPoints, optional Bool bUseMedicineSkill)
{
    local int adjustedHealAmount;

    adjustedHealAmount = _HealPlayer(baseHealPoints, bUseMedicineSkill);

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

exec function ActivateAugmentation(int num)
{
    local Augmentation anAug;
    local int count, wantedSlot, slotIndex;
    local bool bFound;

    if (RestrictInput())
        return;

    anAug = AugmentationSystem.GetAugByKey(num);
    if (Energy == 0 && anAug.GetEnergyRate() > 0 && !anAug.bAutomatic)
    {
        ClientMessage(EnergyDepleted);
        PlaySound(AugmentationSystem.FirstAug.DeactivateSound, SLOT_None);
        return;
    }

    if (AugmentationSystem != None)
        AugmentationSystem.ActivateAugByKey(num);
}

//
// If player chose to dual map the F keys, DXRando: don't directly activate the aug, that avoids the energy check
//
exec function DualmapF3() { ActivateAugmentation(0); }
exec function DualmapF4() { ActivateAugmentation(1); }
exec function DualmapF5() { ActivateAugmentation(2); }
exec function DualmapF6() { ActivateAugmentation(3); }
exec function DualmapF7() { ActivateAugmentation(4); }
exec function DualmapF8() { ActivateAugmentation(5); }
exec function DualmapF9() { ActivateAugmentation(6); }
exec function DualmapF10() { ActivateAugmentation(7); }
exec function DualmapF11() { ActivateAugmentation(8); }
exec function DualmapF12() { ActivateAugmentation(9); }

function CreateDrone()
{
    local Vector loc;

    loc = (2.0 + class'SpyDrone'.Default.CollisionRadius + CollisionRadius) * Vector(ViewRotation);
    loc.Z = BaseEyeHeight;
    loc += Location;
    aDrone = Spawn(class'SpyDrone', Self,, loc, ViewRotation);
    SetDroneStats();
}

function SetDroneStats()
{
    if (aDrone != None)
    {
        //aDrone.Speed = 3 * spyDroneLevelValue;
        aDrone.Speed = 5 * spyDroneLevelValue;
        //aDrone.MaxSpeed = 3 * spyDroneLevelValue;
        aDrone.MaxSpeed = 5 * spyDroneLevelValue;
        //aDrone.Damage = 5 * spyDroneLevelValue;
        aDrone.Damage = 2 * spyDroneLevelValue;
        //aDrone.blastRadius = 8 * spyDroneLevelValue;
        aDrone.blastRadius = 4 * spyDroneLevelValue;
        // window construction now happens in Tick()
    }
}

simulated function MoveDrone( float DeltaTime, Vector loc )
{
    if(aDrone == None) {
        // just in case the drone got killed
        DroneExplode();
        return;
    }
    aDrone.MoveDrone(DeltaTime, loc);// DXRando: this doesn't belong in the player...
}

function DroneExplode()
{
    local AugDrone anAug;

    if (aDrone == None) {
        anAug = AugDrone(AugmentationSystem.FindAugmentation(class'AugDrone'));
        if (anAug != None) anAug.Deactivate();
        return;
    }

    if(Energy >= 10) {
        Energy -= 10;
        Super.DroneExplode();
    } else {
        ClientMessage("You need 10 bio-electric energy to detonate the spy drone.");
    }
}

state PlayerWalking
{
    // lets us affect the player's movement
    // DXRando: we need to copy-paste everything to mess with movement speed https://github.com/Die4Ever/deus-ex-randomizer/issues/842
    function ProcessMove(float DeltaTime, vector newAccel, eDodgeDir DodgeMove, rotator DeltaRot)
    {
        local int newSpeed, defSpeed;
        local name mat;
        local vector HitLocation, HitNormal, checkpoint, downcheck;
        local Actor HitActor, HitActorDown;
        local bool bCantStandUp;
        local Vector loc, traceSize;
        local float alpha, maxLeanDist;
        local float legTotal, weapSkill, augValue, carriedMass;

        // if the spy drone augmentation is active
        if (bSpyDroneActive)
        {
            if ( aDrone != None )
            {
                // put away whatever is in our hand
                if (inHand != None)
                    PutInHand(None);

                // make the drone's rotation match the player's view
                aDrone.SetRotation(ViewRotation);

                // move the drone
                loc = Normal((aUp * vect(0,0,1) + aForward * vect(1,0,0) + aStrafe * vect(0,1,0)) >> ViewRotation);

                // opportunity for client to translate movement to server
                MoveDrone( DeltaTime, loc );

                // freeze the player
                Velocity = vect(0,0,0);
            }
            return;
        }

        defSpeed = GetCurrentGroundSpeed();

        // crouching makes you two feet tall
        if (bIsCrouching || bForceDuck)
        {
            if ( Level.NetMode != NM_Standalone )
                SetBasedPawnSize(Default.CollisionRadius, 30.0);
            else
                SetBasedPawnSize(Default.CollisionRadius, 16);

            // check to see if we could stand up if we wanted to
            checkpoint = Location;
            // check normal standing height
            checkpoint.Z = checkpoint.Z - CollisionHeight + 2 * GetDefaultCollisionHeight();
            traceSize.X = CollisionRadius;
            traceSize.Y = CollisionRadius;
            traceSize.Z = 1;
            HitActor = Trace(HitLocation, HitNormal, checkpoint, Location, True, traceSize);
            if (HitActor == None)
                bCantStandUp = False;
            else
                bCantStandUp = True;
        }
        else
        {
            // DEUS_EX AMSD Changed this to grab defspeed, because GetCurrentGroundSpeed takes 31k cycles to run.
            GroundSpeed = defSpeed;

            // make sure the collision height is fudged for the floor problem - CNN
            if (!IsLeaning())
            {
                ResetBasedPawnSize();
            }
        }

        if (bCantStandUp)
            bForceDuck = True;
        else
            bForceDuck = False;

        // if the player's legs are damaged, then reduce our speed accordingly
        newSpeed = defSpeed;

        if ( Level.NetMode == NM_Standalone )
        {
            if (HealthLegLeft < 1)
                newSpeed -= (defSpeed/2) * 0.25;
            else if (HealthLegLeft < default.HealthLegLeft * 0.34)
                newSpeed -= (defSpeed/2) * 0.15;
            else if (HealthLegLeft < default.HealthLegLeft * 0.67)
                newSpeed -= (defSpeed/2) * 0.10;

            if (HealthLegRight < 1)
                newSpeed -= (defSpeed/2) * 0.25;
            else if (HealthLegRight < default.HealthLegRight * 0.34)
                newSpeed -= (defSpeed/2) * 0.15;
            else if (HealthLegRight < default.HealthLegRight * 0.67)
                newSpeed -= (defSpeed/2) * 0.10;

            if (HealthTorso < default.HealthTorso * 0.67)
                newSpeed -= (defSpeed/2) * 0.05;
        }

        // let the player pull themselves along with their hands even if both of
        // their legs are blown off
        if ((HealthLegLeft < 1) && (HealthLegRight < 1))
        {
            newSpeed = defSpeed * 0.8;
            bIsWalking = True;
            bForceDuck = True;
        }
        // make crouch speed faster than normal
        else if (bIsCrouching || bForceDuck)
        {
            //newSpeed = defSpeed * 1.8;		// DEUS_EX CNN - uncomment to speed up crouch
            bIsWalking = True;
        }

        // CNN - Took this out because it sucks ASS!
        // if the legs are seriously damaged, increase the head bob
        // (unless the player has turned it off)
        /*if (Bob > 0.0)
        {
            legTotal = (HealthLegLeft + HealthLegRight) / 2.0;
            if (legTotal < 50)
                Bob = Default.Bob * FClamp(0.05*(70 - legTotal), 1.0, 3.0);
            else
                Bob = Default.Bob;
        }
        */

        // slow the player down if he's carrying something heavy
        // Like a DEAD BODY!  AHHHHHH!!!
        // old vanilla code commented out
        /*if (CarriedDecoration != None)
        {
            newSpeed -= CarriedDecoration.Mass * 2;
        }
        // don't slow the player down if he's skilled at the corresponding weapon skill
        else if ((DeusExWeapon(Weapon) != None) && (Weapon.Mass > 30) && (DeusExWeapon(Weapon).GetWeaponSkill() > -0.25) && (Level.NetMode==NM_Standalone))
        {
            bIsWalking = True;
            newSpeed = defSpeed;
        }
        else if ((inHand != None) && inHand.IsA('POVCorpse'))
        {
            newSpeed -= inHand.Mass * 3;
        }*/
        // DXRando: mix it up https://github.com/Die4Ever/deus-ex-randomizer/issues/842
        // AugMuscle now helps carrying decorations and bodies
        if (AugmentationSystem != None)
            augValue = AugmentationSystem.GetAugLevelValue(class'AugMuscle');
        augValue = FClamp(augValue, 1, 5);
        if (CarriedDecoration != None)
            carriedMass = CarriedDecoration.Mass;
        if(inHand != None && POVCorpse(inHand) != None)
            carriedMass = inHand.Mass;
        newSpeed -= (carriedMass * 2) / (augValue ** 2);
        // adjust player speed according to weapon skill, and AugMuscle
        if (DeusExWeapon(Weapon) != None && Weapon.Mass > 30 && Level.NetMode==NM_Standalone && !bIsWalking)
        {
            weapSkill = DeusExWeapon(Weapon).GetWeaponSkill() * -2 + 1;// 1.0 == 100%
            weapSkill += (augValue - 1) * 2; // 125% AugMuscle (level 1) gives +50% skill, equivalent to 150% weapon skill (advanced)
            weapSkill = (weapSkill - 1) / 0.6;// subtract away the lower bound (100%) so it's 0, then divided by the span (upper - lower) so we're on an 0 to 1 scale
            weapSkill = FClamp(weapSkill, 0, 1);
            newSpeed = (newSpeed / 3 * (1 - weapSkill)) + (newSpeed * weapSkill);
        }

        // Multiplayer movement adjusters
        if ( Level.NetMode != NM_Standalone )
        {
            if ( Weapon != None )
            {
                weapSkill = DeusExWeapon(Weapon).GetWeaponSkill();
                // Slow down heavy weapons in multiplayer
                if ((DeusExWeapon(Weapon) != None) && (Weapon.Mass > 30) )
                {
                    newSpeed = defSpeed;
                    newSpeed -= ((( Weapon.Mass - 30.0 ) / (class'WeaponGEPGun'.Default.Mass - 30.0 )) * (0.70 + weapSkill) * defSpeed );
                }
                // Slow turn rate of GEP gun in multiplayer to discourage using it as the most effective close quarters weapon
                if ((WeaponGEPGun(Weapon) != None) && (!WeaponGEPGun(Weapon).bZoomed))
                    TurnRateAdjuster = FClamp( 0.20 + -(weapSkill*0.5), 0.25, 1.0 );
                else
                    TurnRateAdjuster = 1.0;
            }
            else
                TurnRateAdjuster = 1.0;
        }

        // if we are moving really slow, force us to walking
        if ((newSpeed <= defSpeed / 3) && !bForceDuck)
        {
            bIsWalking = True;
            newSpeed = defSpeed;
        }

        // if we are moving backwards, we should move slower
        // DEUS_EX AMSD Turns out this wasn't working right in multiplayer, I have a fix
        // for it, but it would change all our balance.
        if ((aForward < 0) && (Level.NetMode == NM_Standalone))
            newSpeed *= 0.65;

        GroundSpeed = FMax(newSpeed, 100);
        if(Level.LevelAction != LEVACT_None) GroundSpeed = 0;// DXRando: don't move during loading/randomization/autosave
        else if(DeltaTime > 0.1 && class'MenuChoice_FixGlitches'.default.enabled) {// for quicksaves
            GroundSpeed *= FClamp(0.25 / DeltaTime, 0.5, 0.85);// DXRando: anyone running the game at 10fps?
        }

        // if we are moving or crouching, we can't lean
        // uncomment below line to disallow leaning during crouch

        if ((VSize(Velocity) < 10) && (aForward == 0))		// && !bIsCrouching && !bForceDuck)
            bCanLean = True;
        else
            bCanLean = False;

        // check leaning buttons (axis aExtra0 is used for leaning)
        maxLeanDist = 40;

        if (IsLeaning())
        {
            if ( PlayerIsClient() || (Level.NetMode == NM_Standalone) )
                ViewRotation.Roll = curLeanDist * 20;

            if (!bIsCrouching && !bForceDuck)
                SetBasedPawnSize(CollisionRadius, GetDefaultCollisionHeight() - Abs(curLeanDist) / 3.0);
        }
        if (bCanLean && (aExtra0 != 0))
        {
            // lean
            DropDecoration();		// drop the decoration that we are carrying
            if (AnimSequence != 'CrouchWalk')
                PlayCrawling();

            alpha = maxLeanDist * aExtra0 * 2.0 * DeltaTime;

            loc = vect(0,0,0);
            loc.Y = alpha;
            if (Abs(curLeanDist + alpha) < maxLeanDist)
            {
                // check to make sure the destination not blocked
                checkpoint = (loc >> Rotation) + Location;
                traceSize.X = CollisionRadius;
                traceSize.Y = CollisionRadius;
                traceSize.Z = CollisionHeight;
                HitActor = Trace(HitLocation, HitNormal, checkpoint, Location, True, traceSize);

                // check down as well to make sure there's a floor there
                downcheck = checkpoint - vect(0,0,1) * CollisionHeight;
                HitActorDown = Trace(HitLocation, HitNormal, downcheck, checkpoint, True, traceSize);
                if ((HitActor == None) && (HitActorDown != None))
                {
                    if ( PlayerIsClient() || (Level.NetMode == NM_Standalone))
                    {
                        SetLocation(checkpoint);
                        ServerUpdateLean( checkpoint );
                        curLeanDist += alpha;
                    }
                }
            }
            else
            {
                if ( PlayerIsClient() || (Level.NetMode == NM_Standalone) )
                    curLeanDist = aExtra0 * maxLeanDist;
            }
        }
        else if (IsLeaning())	//if (!bCanLean && IsLeaning())	// uncomment this to not hold down lean
        {
            // un-lean
            if (AnimSequence == 'CrouchWalk')
                PlayRising();

            if ( PlayerIsClient() || (Level.NetMode == NM_Standalone))
            {
                prevLeanDist = curLeanDist;
                alpha = FClamp(7.0 * DeltaTime, 0.001, 0.9);
                curLeanDist *= 1.0 - alpha;
                if (Abs(curLeanDist) < 1.0)
                    curLeanDist = 0;
            }

            loc = vect(0,0,0);
            loc.Y = -(prevLeanDist - curLeanDist);

            // check to make sure the destination not blocked
            checkpoint = (loc >> Rotation) + Location;
            traceSize.X = CollisionRadius;
            traceSize.Y = CollisionRadius;
            traceSize.Z = CollisionHeight;
            HitActor = Trace(HitLocation, HitNormal, checkpoint, Location, True, traceSize);

            // check down as well to make sure there's a floor there
            downcheck = checkpoint - vect(0,0,1) * CollisionHeight;
            HitActorDown = Trace(HitLocation, HitNormal, downcheck, checkpoint, True, traceSize);
            if ((HitActor == None) && (HitActorDown != None))
            {
                if ( PlayerIsClient() || (Level.NetMode == NM_Standalone))
                {
                    SetLocation( checkpoint );
                    ServerUpdateLean( checkpoint );
                }
            }
        }

        PlayerPawnProcessMove(DeltaTime, newAccel, DodgeMove, DeltaRot);
    }

    // can't call Super(PlayerPawn.PlayerWalking).ProcessMove, so we gotta copy-paste it too...
    function PlayerPawnProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
    {
        local vector OldAccel;

        OldAccel = Acceleration;
        Acceleration = NewAccel;
        bIsTurning = ( Abs(DeltaRot.Yaw/DeltaTime) > 5000 );
        if ( (DodgeMove == DODGE_Active) && (Physics == PHYS_Falling) )
            DodgeDir = DODGE_Active;
        else if ( (DodgeMove != DODGE_None) && (DodgeMove < DODGE_Active) )
            Dodge(DodgeMove);

        if ( bPressedJump )
            DoJump();
        if ( (Physics == PHYS_Walking) && (GetAnimGroup(AnimSequence) != 'Dodge') )
        {
            if (!bIsCrouching)
            {
                if (bDuck != 0)
                {
                    bIsCrouching = true;
                    PlayDuck();
                }
            }
            else if (bDuck == 0)
            {
                OldAccel = vect(0,0,0);
                bIsCrouching = false;
                TweenToRunning(0.1);
            }

            if ( !bIsCrouching )
            {
                if ( (!bAnimTransition || (AnimFrame > 0)) && (GetAnimGroup(AnimSequence) != 'Landing') )
                {
                    if ( Acceleration != vect(0,0,0) )
                    {
                        if ( (GetAnimGroup(AnimSequence) == 'Waiting') || (GetAnimGroup(AnimSequence) == 'Gesture') || (GetAnimGroup(AnimSequence) == 'TakeHit') )
                        {
                            bAnimTransition = true;
                            TweenToRunning(0.1);
                        }
                    }
                    else if ( (Velocity.X * Velocity.X + Velocity.Y * Velocity.Y < 1000)
                        && (GetAnimGroup(AnimSequence) != 'Gesture') )
                    {
                        if ( GetAnimGroup(AnimSequence) == 'Waiting' )
                        {
                            if ( bIsTurning && (AnimFrame >= 0) )
                            {
                                bAnimTransition = true;
                                PlayTurning();
                            }
                        }
                        else if ( !bIsTurning )
                        {
                            bAnimTransition = true;
                            TweenToWaiting(0.2);
                        }
                    }
                }
            }
            else
            {
                if ( (OldAccel == vect(0,0,0)) && (Acceleration != vect(0,0,0)) )
                    PlayCrawling();
                else if ( !bIsTurning && (Acceleration == vect(0,0,0)) && (AnimFrame > 0.1) )
                    PlayDuck();
            }
        }
    }
}

// just in case it tries to get called from a different state, to prevent "Failed to find function" crashes
function PlayerPawnProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)
{
}

function PickupNanoKey(NanoKey newKey)
{
    if (!class'DXRVersion'.static.VersionIsStable() && newKey.keyID==''){
        ClientMessage("You just picked up a key without a key ID!  Report this to the devs, we're looking for this!  Where did you find me?");
    }
    Super.PickupNanoKey(newKey);
}
