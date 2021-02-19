class DXRPlayer injects Human;

var DXRando dxr;
var DXRLoadouts loadout;

function DXRBase DXRFindModule(class<DXRBase> class)
{
    local DXRBase m;
    if( dxr == None ) foreach AllActors(class'DXRando', dxr) { break; }
    if( dxr != None ) m = dxr.FindModule(class);
    return m;
}

function bool AddInventory( inventory NewItem )
{
    if( loadout == None ) loadout = DXRLoadouts(DXRFindModule(class'DXRLoadouts'));
    if ( loadout != None && loadout.ban(self, NewItem) ) return true;

    return Super.AddInventory(NewItem);
}

function float GetCurrentGroundSpeed()
{
    local float augValue, speed;

    // Remove this later and find who's causing this to Access None MB
    if ( AugmentationSystem == None )
        return 0;

    augValue = AugmentationSystem.GetAugLevelValue(class'AugSpeed');
    if (augValue == -1.0)
        augValue = AugmentationSystem.GetAugLevelValue(class'AugNinja');

    if (augValue == -1.0)
        augValue = 1.0;

    if (( Level.NetMode != NM_Standalone ) && Self.IsA('Human') )
        speed = Self.mpGroundSpeed * augValue;
    else
        speed = Default.GroundSpeed * augValue;

    return speed;
}

function DoJump( optional float F )
{
    local DeusExWeapon w;
    local float scaleFactor, augLevel;

    if ((CarriedDecoration != None) && (CarriedDecoration.Mass > 20))
        return;
    else if (bForceDuck || IsLeaning())
        return;

    if (Physics == PHYS_Walking)
    {
        if ( Role == ROLE_Authority )
            PlaySound(JumpSound, SLOT_None, 1.5, true, 1200, 1.0 - 0.2*FRand() );
        if ( (Level.Game != None) && (Level.Game.Difficulty > 0) )
            MakeNoise(0.1 * Level.Game.Difficulty);
        PlayInAir();

        Velocity.Z = JumpZ;

        if ( Level.NetMode != NM_Standalone )
        {
         if (AugmentationSystem == None)
            augLevel = -1.0;
         else			
            augLevel = AugmentationSystem.GetAugLevelValue(class'AugSpeed');
            if( augLevel == -1.0 )
                augLevel = AugmentationSystem.GetAugLevelValue(class'AugNinja');
            w = DeusExWeapon(InHand);
            if ((augLevel != -1.0) && ( w != None ) && ( w.Mass > 30.0))
            {
                scaleFactor = 1.0 - FClamp( ((w.Mass - 30.0)/55.0), 0.0, 0.5 );
                Velocity.Z *= scaleFactor;
            }
        }
        
        // reduce the jump velocity if you are crouching
//		if (bIsCrouching)
//			Velocity.Z *= 0.9;

        if ( Base != Level )
            Velocity.Z += Base.Velocity.Z;
        SetPhysics(PHYS_Falling);
        if ( bCountJumps && (Role == ROLE_Authority) )
            Inventory.OwnerJumped();
    }
}

function Landed(vector HitNormal)
{
    local vector legLocation;
    local int augLevel;
    local float augReduce, dmg;

    //Note - physics changes type to PHYS_Walking by default for landed pawns
    PlayLanded(Velocity.Z);
    if (Velocity.Z < -1.4 * JumpZ)
    {
        MakeNoise(-0.5 * Velocity.Z/(FMax(JumpZ, 150.0)));
        if ((Velocity.Z < -700) && (ReducedDamageType != 'All'))
            if ( Role == ROLE_Authority )
            {
                // check our jump augmentation and reduce falling damage if we have it
                // jump augmentation doesn't exist anymore - use Speed instaed
                // reduce an absolute amount of damage instead of a relative amount
                augReduce = 0;
                if (AugmentationSystem != None)
                {
                    augLevel = AugmentationSystem.GetClassLevel(class'AugSpeed');
                    if( augLevel == -1.0 )
                        augLevel = AugmentationSystem.GetClassLevel(class'AugNinja');
                    if (augLevel >= 0)
                        augReduce = 15 * (augLevel+1);
                }

                dmg = Max((-0.16 * (Velocity.Z + 700)) - augReduce, 0);
                legLocation = Location + vect(-1,0,-1);			// damage left leg
                TakeDamage(dmg, None, legLocation, vect(0,0,0), 'fell');

                legLocation = Location + vect(1,0,-1);			// damage right leg
                TakeDamage(dmg, None, legLocation, vect(0,0,0), 'fell');

                dmg = Max((-0.06 * (Velocity.Z + 700)) - augReduce, 0);
                legLocation = Location + vect(0,0,1);			// damage torso
                TakeDamage(dmg, None, legLocation, vect(0,0,0), 'fell');
            }
    }
    else if ( (Level.Game != None) && (Level.Game.Difficulty > 1) && (Velocity.Z > 0.5 * JumpZ) )
        MakeNoise(0.1 * Level.Game.Difficulty);				
    bJustLanded = true;
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

    bReduced = False;
    newDamage = Float(Damage);
    oldDamage = newDamage;

    if ((damageType == 'TearGas') || (damageType == 'PoisonGas') || (damageType == 'Radiation') ||
        (damageType == 'HalonGas')  || (damageType == 'PoisonEffect') || (damageType == 'Poison') 
        /*|| damageType == 'Flamed' || damageType == 'Burned'*/ )
    {
        if (AugmentationSystem != None)
            augLevel = AugmentationSystem.GetAugLevelValue(class'AugEnviro');

        if (augLevel >= 0.0)
            newDamage *= augLevel;

        // get rid of poison if we're maxed out
        if (newDamage ~= 0.0)
        {
            StopPoison();
            drugEffectTimer -= 4;	// stop the drunk effect
            if (drugEffectTimer < 0)
                drugEffectTimer = 0;
        }

        if (UsingChargedPickup(class'HazMatSuit'))
        {
            skillLevel = SkillSystem.GetSkillLevelValue(class'SkillEnviro');
            newDamage *= 0.75 * skillLevel;
        }
    }

    if ((damageType == 'Shot') || (damageType == 'Sabot') || (damageType == 'Exploded') || (damageType == 'AutoShot'))
    {
        // go through the actor list looking for owned BallisticArmor
        // since they aren't in the inventory anymore after they are used
        if (UsingChargedPickup(class'BallisticArmor'))
        {
            skillLevel = SkillSystem.GetSkillLevelValue(class'SkillEnviro');
            newDamage *= 0.5 * skillLevel;
        }
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
    damageMult = flagBase.GetFloat('cc_damageMult');
    if (damageMult!=0) {
        newDamage*=damageMult;
    }


    //
    // Reduce or increase the damage based on the combat difficulty setting, do this before SetDamagePercent for the UI display
    // because we don't want to show 100% damage reduction but then do the minimum of 1 damage
    if ((damageType == 'Shot') || (damageType == 'AutoShot') ||
        damageType == 'Flamed' || damageType == 'Burned')
    {
        newDamage *= CombatDifficulty;
        oldDamage *= CombatDifficulty;

        // always take at least one point of damage
        if ((newDamage <= 1) && (Damage > 0))
            newDamage = 1;
        if ((oldDamage <= 1) && (Damage > 0))
            oldDamage = 1;
    }

    if (newDamage < oldDamage)
    {
        if (!bCheckOnly)
        {
            //make sure to factor the rounding into the percentage
            pct = 1.0 - ( Float(Int(newDamage)) / Float(Int(oldDamage)) );
            SetDamagePercent(pct);
            ClientFlash(0.01, vect(0, 0, 50));
        }
        bReduced = True;
    }
    else
    {
        if (!bCheckOnly)
            SetDamagePercent(0.0);
    }

    adjustedDamage = Int(newDamage);

    return bReduced;
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
