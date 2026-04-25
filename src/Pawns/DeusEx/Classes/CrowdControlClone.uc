class CrowdControlClone extends #var(prefix)JCDouble;

var int numMedkits;
var int numBiocells;
var int numFireExtinguishers;

var int MedkitStrength;
var float CloneEMPHealth; //Handled differently than standard DXRando EMPHealth, and across mods
var float CloneMaxEMPHealth;

//Augs
var float CloakValue;
var float BallisticProtValue;
var float EnergyShieldValue;
var float EnviroProtectionValue;
var float EMPShieldValue;
var float SpeedValue;
//Could implement Aggressive Defense System?
//Could implement Regeneration
//Could implement Power Recirculator

#ifndef vmd
var DXRFashionManager fashion;
#endif

function BeginPlay()
{
    SetTimer(1.0,true); //Checking if the clone should use a medkit or biocell
}

function InitFromPlayer(#var(PlayerPawn) p)
{
    local int i;

    #ifndef hx
    SetSkin(p);
    #endif

    //Copy the player appearance
    Mesh = p.Mesh;
    Texture = p.Texture;
    for(i=0;i<ArrayCount(Multiskins);i++){
        Multiskins[i]=p.Multiskins[i];
        Default.Multiskins[i]=p.Multiskins[i]; //This helps with the face
    }

    //Grab female sounds if necessary
    HitSound1 = p.HitSound1;
    HitSound2 = p.HitSound2;
    Die = p.Die;

    #ifndef vmd
    //Make them use the JCDentonMaleCarcass, since it will be adjusted for FemJC anyway
    CarcassType = class'JCDentonMaleCarcass';
    #endif

    SetMaxHealth(p.Default.Health * 3); //Stronger than the player

    UnfamiliarName = p.TruePlayerName;
    FamiliarName = p.TruePlayerName;

#ifndef vmd
    //Make sure they're dressed like you
    fashion = class'DXRFashionManager'.static.GiveItem(p);
    fashion.GetDressed();
#endif

    CloneInventory(p);
    CloneAugs(p);

    //How much should the clones medkits heal?
    if (p.SkillSystem!=None){
        MedkitStrength = Default.MedkitStrength * p.SkillSystem.GetSkillLevelValue(class'SkillMedicine');
    }
}

function SetMaxHealth(int maxHealth)
{
    default.Health = maxHealth;
    default.HealthHead = maxHealth;
    default.HealthTorso = maxHealth;
    default.HealthLegLeft = maxHealth;
    default.HealthLegRight = maxHealth;
    default.HealthArmLeft = maxHealth;
    default.HealthArmRight = maxHealth;
    HealthHead = maxHealth;
    HealthTorso = maxHealth;
    HealthLegLeft = maxHealth;
    HealthLegRight = maxHealth;
    HealthArmLeft = maxHealth;
    HealthArmRight = maxHealth;
    GenerateTotalHealth();
}

//Clone the player weapons and ammo into the... Clone
//Might be nice to copy armour into the clone for VMD, where they'll actually use them (but need to make them not drop the armour as well)
function CloneInventory(#var(PlayerPawn) p)
{
    local Inventory pInv,newInv;
    local #var(DeusExPrefix)Ammo dxAmmo,newAmmo;
    local #var(DeusExPrefix)Weapon dxWeap,newWeap;
    local DXRActorsBase dxrab;

    dxrab = DXRActorsBase(class'DXRActorsBase'.static.Find());

    for(pInv = p.Inventory;pInv!=None;pInv=pInv.Inventory){
        newAmmo = None;
        newWeap = None;

        dxAmmo = #var(DeusExPrefix)Ammo(pInv);
        dxWeap = #var(DeusExPrefix)Weapon(pInv);
        if (dxAmmo!=None || dxWeap!=None){
            newInv =  dxrab.GiveItem(self,pInv.Class,1);
            newAmmo = #var(DeusExPrefix)Ammo(newInv);
            newWeap = #var(DeusExPrefix)Weapon(newInv);
        } else if (#var(prefix)Medkit(pInv)!=None){
            numMedkits += #var(prefix)Medkit(pInv).NumCopies;
        } else if (#var(prefix)BioelectricCell(pInv)!=None){
            numBiocells += #var(prefix)BioelectricCell(pInv).NumCopies;
        } else if (#var(prefix)FireExtinguisher(pInv)!=None){
            numFireExtinguishers += #var(prefix)FireExtinguisher(pInv).NumCopies;
        }

        if (dxAmmo!=None && newAmmo!=None){
            //Give the clone just as much ammo as the player has
            newAmmo.AmmoAmount = dxAmmo.AmmoAmount;
        }

        if (newWeap!=None){
            newWeap.bNativeAttack=True; //Mark as Native so that the clone doesn't drop it
        }
    }
}

function float PreviewPlayerAugLevelValue(#var(PlayerPawn) p, Class<Augmentation> findClass)
{
    local Augmentation aug;

    if (p==None) return -1.0;
    if (p.AugmentationSystem==None) return -1.0;

    aug = p.AugmentationSystem.FindAugmentation(findClass);

    if (aug==None) return -1.0;
    if (aug.bHasIt==false) return -1.0;

    //Can't use GetAugLevelValue because it ticks energy, can't use PreviewAugLevelValue because it checks energy, etc
    //Just manually check the level values
    if (aug.CurrentLevel<4){
        return aug.LevelValues[aug.CurrentLevel];
    } else {
    #ifdef injections
        if (aug.CurrentLevel>=4){
            return aug.Level5Value;
        }
        return 1.0;
    #endif
    }
    return -1.0;
}

function CloneAugs(#var(PlayerPawn) p)
{
    CloneEMPHealth = p.Energy;
    CloneMaxEMPHealth = p.Default.Energy;

    if (p.AugmentationSystem==None) return; //No augs, I guess

    CloakValue=PreviewPlayerAugLevelValue(p,class'AugCloak');
    BallisticProtValue=PreviewPlayerAugLevelValue(p,class'AugBallistic');
    EnergyShieldValue=PreviewPlayerAugLevelValue(p,class'AugShield');
    EnviroProtectionValue=PreviewPlayerAugLevelValue(p,class'AugEnviro');
    EMPShieldValue=PreviewPlayerAugLevelValue(p,class'AugEMP');
    SpeedValue=PreviewPlayerAugLevelValue(p,class'AugSpeed');
    #ifndef vmd
    //Also check Running Enhancement
    SpeedValue=FMax(SpeedValue,PreviewPlayerAugLevelValue(p,class'AugOnlySpeed'));
    #endif

}

function float ShieldDamage(Name damageType)
{
    local float reduction;
    local float energyUsed;

    reduction = 1.0;
    energyUsed = 0;

    //Energy Shield
    if ((damageType == 'Burned') || (damageType == 'Flamed') ||
        (damageType == 'Exploded') || (damageType == 'Shocked'))
    {
        if (CloneEMPHealth>0 && EnergyShieldValue>=0){
            energyUsed += 0.5;
            reduction = FMin(reduction,EnergyShieldValue);
        }
    }

    //EMP Shield (for shock)
    if (damageType=='Shocked'){
        if (CloneEMPHealth>0 && EMPShieldValue>=0){
            energyUsed += 0.25;
            reduction = FMin(reduction,EMPShieldValue);
        }
    }

    //Environmental Protection
    if ((damageType == 'TearGas') || (damageType == 'PoisonGas') || (damageType == 'Radiation') ||
        (damageType == 'HalonGas')  || (damageType == 'PoisonEffect') || (damageType == 'Poison'))
    {
        if (CloneEMPHealth>0 && EnviroProtectionValue>=0){
            energyUsed += 0.25;
            reduction = FMin(reduction,EnviroProtectionValue);
        }
    }

    //Ballistic Protection
    if ((damageType == 'Shot') || (damageType == 'AutoShot')){
        if (CloneEMPHealth>0 && BallisticProtValue>=0){
            energyUsed += 0.5;
            reduction = FMin(reduction,BallisticProtValue);
        }
    }

    CloneEMPHealth = FMax(0,CloneEMPHealth - energyUsed);

    return reduction;
}

#ifdef revision
function float ModifyDamage(int Damage, Pawn instigatedBy, Vector hitLocation,
                            Vector offset, Name damageType, optional bool bTestOnly)
#else
function float ModifyDamage(int Damage, Pawn instigatedBy, Vector hitLocation,
                            Vector offset, Name damageType)
#endif
{
    if (damageType=='EMP'){
        if (EMPShieldValue>=0 && CloneEMPHealth>0){
            Damage = Damage * EMPShieldValue;
            //allow the damage to go through, we'll fully shield in ShieldDamage so it doesn't actually hurt
        }
        //Our ScriptedPawn fixes use this function to do some danger checks, don't take EMP damage from those
        if (instigatedBy!=self && hitLocation!=vect(0,0,0) && offset!=vect(0,0,0)){
            CloneEMPHealth = FMax(0,CloneEMPHealth-Damage);
        }
    }

#ifdef revision
    return Super.ModifyDamage(Damage, instigatedBy, hitLocation, offset, damageType, bTestOnly);
#else
    return Super.ModifyDamage(Damage, instigatedBy, hitLocation, offset, damageType);
#endif
}

#ifdef revision
function bool FilterDamageType(Pawn instigatedBy, Vector hitLocation,
                               Vector offset, Name damageType, optional bool bTestOnly)
#else
function bool FilterDamageType(Pawn instigatedBy, Vector hitLocation,
                               Vector offset, Name damageType)
#endif
{
    if (damageType == 'HalonGas'){
        if (bOnFire){
            ExtinguishFire();
        }
        return false; //Player isn't stopped by halon, neither is a clone
    }

    if (damageType == 'EMP')
    {
        CloakEMPTimer += 10;  // hack - replace with skill-based value
        if (CloakEMPTimer > 20)
            CloakEMPTimer = 20;
        EnableCloak(bCloakOn);
        //Don't immediately filter, allow ModifyDamage to get hit, at least
    }

    return true;
}

#ifndef vmd
function ResetSkinStyle()
{
    local DXRFashionManager fashion;

    //This normally resets the textures to defaults (But does not change the mesh, obv)
    Super.ResetSkinStyle();

    //Make sure you're dressed
    if (fashion!=None){
        fashion.GetDressed();
    }
}
#endif

function bool ShouldBeCloaked()
{
    if(CloneEMPHealth <= 0) return False;
    if(CloakValue <= 0) return False;

    switch(GetStateName()){
        case 'Seeking':
        case 'Alerting':
        case 'Attacking':
        case 'Fleeing':
            return True;
            break;
        default:
            return False;
            break;
    }
    return False;
}

function EnableCloak(bool bEnable)  // beware! called from C++
{
    if (!bHasCloak || (CloakEMPTimer > 0) || (Health <= 0) || bOnFire)
        bEnable = false;

    if (bEnable && !bCloakOn)
    {
        SetSkinStyle(STY_Translucent, Texture'WhiteStatic', 0.25);
        KillShadow();
        bCloakOn = bEnable;
        bUnlit = True; //Makes the stealth effect consistent, regardless of lighting

    }
    else if (!bEnable && bCloakOn)
    {
        ResetSkinStyle();
        CreateShadow();
        bCloakOn = bEnable;
        bUnlit = False;
    }
}

function bool ShouldUseSpeed()
{
    if(CloneEMPHealth <= 0) return False;
    if(SpeedValue <= 0) return False;

    switch(GetStateName()){
        case 'Seeking':
        case 'Alerting':
        case 'Attacking':
        case 'Fleeing':
            return True;
            break;
        default:
            return False;
            break;
    }
    return False;
}

function bool NeedsToHeal()
{
    if (Health < (Default.Health/2)) return True;

    if (HealthHead     < (Default.HealthHead/2))     return True;
    if (HealthTorso    < (Default.HealthTorso/2))    return True;
    if (HealthLegLeft  < (Default.HealthLegLeft/2))  return True;
    if (HealthLegRight < (Default.HealthLegRight/2)) return True;
    if (HealthArmLeft  < (Default.HealthArmLeft/2))  return True;
    if (HealthArmRight < (Default.HealthArmRight/2)) return True;

    return False;
}

function Timer()
{
    local int i,healAmount,remainingHeals,before,start;
    local bool unpanic,canUseItems;
    local ProjectileGenerator gen;
    local Vector loc;
    local Rotator rot;

    if (IsInState('Dying')) return;

    if(bOnFire){
        //Default timer behaviour does this without any sort of check...
        UpdateFire();
    }

    //Can't use items if you're rubbing your eyes (gas) or you've been stunned (prod)
    //This isn't reflected by the player obviously (since you don't get stunlocked)
    //but is kind of an interesting counter, I guess?
    canUseItems = true;
    if (IsInState('RubbingEyes') || IsInState('Stunned')){
        canUseItems=false;
    }

    if (canUseItems && numMedkits > 0){
        if (NeedsToHeal()){
            numMedkits--;

            remainingHeals = MedkitStrength;
            i = MedkitStrength/6; //Per body part

            while(remainingHeals>0){
                start = remainingHeals;

                before = HealthHead;
                healAmount = Min(i,remainingHeals);
                HealthHead = Min(Default.HealthHead,HealthHead+i);
                remainingHeals = remainingHeals - (HealthHead-before);

                before = HealthTorso;
                healAmount = Min(i,remainingHeals);
                HealthTorso = Min(Default.HealthTorso,HealthTorso+healAmount);
                remainingHeals = remainingHeals - (HealthTorso-before);

                before = HealthLegLeft;
                healAmount = Min(i,remainingHeals);
                HealthLegLeft = Min(Default.HealthLegLeft,HealthLegLeft+healAmount);
                remainingHeals = remainingHeals - (HealthLegLeft-before);

                before = HealthLegRight;
                healAmount = Min(i,remainingHeals);
                HealthLegRight = Min(Default.HealthLegRight,HealthLegRight+healAmount);
                remainingHeals = remainingHeals - (HealthLegRight-before);

                before = HealthArmLeft;
                healAmount = Min(i,remainingHeals);
                HealthArmLeft = Min(Default.HealthArmLeft,HealthArmLeft+healAmount);
                remainingHeals = remainingHeals - (HealthArmLeft-before);

                before = HealthArmRight;
                healAmount = Min(i,remainingHeals);
                HealthArmRight = Min(Default.HealthArmRight,HealthArmRight+healAmount);
                remainingHeals = remainingHeals - (HealthArmRight-before);

                if (start==remainingHeals){
                    break;
                }
            }

            GenerateTotalHealth();

            PlaySound(sound'MedicalHiss', SLOT_None,,, 256);

            unpanic = true;
        }
    }

    if (canUseItems && numBiocells > 0){
        if (CloneEMPHealth < (CloneMaxEMPHealth/2)){
            numBiocells--;
            CloneEMPHealth = Min(CloneMaxEMPHealth,CloneEMPHealth+25);
            PlaySound(sound'BioElectricHiss', SLOT_None,,, 256);
        }
    }

    if (canUseItems && numFireExtinguishers > 0){
        if (bOnFire){
            numFireExtinguishers--;
            ExtinguishFire();

            // spew halon gas (duped from FireExtinguisher)
            rot = ViewRotation;
            loc = Vector(rot) * CollisionRadius;
            loc.Z += CollisionHeight * 0.9;
            loc += Location;
            gen = Spawn(class'ProjectileGenerator', None,, loc, rot);
            if (gen != None)
            {
                gen.ProjectileClass = class'HalonGas';
                gen.SetBase(Self);
                gen.LifeSpan = 3;
                gen.ejectSpeed = 300;
                gen.projectileLifeSpan = 1.5;
                gen.frequency = 0.9;
                gen.checkTime = 0.1;
                gen.bAmbientSound = True;
                gen.AmbientSound = sound'SteamVent2';
                gen.SoundVolume = 192;
                gen.SoundPitch = 32;
            }

            unpanic=true;
        }
    }

    if (unpanic){
        //Make sure they aren't freaking out anymore
        if (IsInState('Fleeing') || IsInState('Burning')){
            FearLevel=0;
            FollowOrders();
        }
    }

    bHasCloak = ShouldBeCloaked();
    EnableCloak(bHasCloak);
    if (bHasCloak){
        CloneEMPHealth-= (300.0 * CloakValue)/60.0;
    }

    if (ShouldUseSpeed()){
        if (GroundSpeed==Default.GroundSpeed){
            //Aug is activating
            PlaySound(Sound'DeusExSounds.Augmentation.AugActivate');
        }
        GroundSpeed = Default.GroundSpeed * SpeedValue;
        CloneEMPHealth-= (class'AugSpeed'.Default.EnergyRate)/60.0;
    } else {
        if (GroundSpeed!=Default.GroundSpeed){
            //Aug is deactivating
            PlaySound(Sound'DeusExSounds.Augmentation.AugDeactivate');
        }
        GroundSpeed = Default.GroundSpeed;
    }

    CloneEMPHealth = FMax(CloneEMPHealth,0); //make sure energy doesn't go negative


}


defaultproperties
{
     bInvincible=False
     BindName="CrowdControlClone"
     FamiliarName="JC Denton Clone"
     UnfamiliarName="JC Denton Clone"
     bReactAlarm=True
     bReactCarcass=True
     bReactDistress=True
     bReactFutz=True
     bReactLoudNoise=True
     bReactPresence=True
     bReactProjectiles=True
     bReactShot=True
     bLeaveAfterFleeing=True
     bKeepWeaponDrawn=True
     MedkitStrength=30
     CloneEMPHealth=100
     CloneMaxEMPHealth=100
     CloakThreshold=9999;
     CloakValue=-1
     BallisticProtValue=-1
     EnergyShieldValue=-1
     EnviroProtectionValue=-1
     EMPShieldValue=-1
     SpeedValue=-1

}
