class DXRWeapon shims DeusExWeapon abstract;

var float blood_mult;
var float anim_speed;

function PostBeginPlay()
{
    local DXRWeapons m;
    Super.PostBeginPlay();

    foreach AllActors(class'DXRWeapons', m) {
        m.RandoWeapon(self);
    }
}

function SpawnBlood(Vector HitLocation, Vector HitNormal)
{
    Super.SpawnBlood(HitLocation, HitNormal);
    SpawnExtraBlood(Self, HitLocation, HitNormal, blood_mult);
}

static function SpawnExtraBlood(Actor this, Vector HitLocation, Vector HitNormal, float mult)
{
    local Actor a;
    local vector v;
    local int i;

    if ((DeusExMPGame(this.Level.Game) != None) && (!DeusExMPGame(this.Level.Game).bSpawnEffects))
        return;

    for (i=0; i < int(mult*2.0); i++)
    {
        v = VRand()*8.0*mult;
        a = this.spawn(class'BloodSpurt',,,HitLocation+HitNormal+v);
        a.DrawScale *= mult;
        a = this.spawn(class'BloodDrop',,,HitLocation+HitNormal*4+v);
        a.DrawScale *= mult;
    }
}

simulated function float AnimSpeed(float e)
{
    if( anim_speed == 1.0 ) return 1.0;
    return class'DXRBase'.static.pow(anim_speed + -0.2 * GetWeaponSkill(), e);
}

simulated function TweenDown()
{
    if ( (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
        TweenAnim( AnimSequence, AnimFrame * 0.4 );
    else
    {
        // Have the put away animation play twice as fast in multiplayer
        if ( Level.NetMode != NM_Standalone )
            PlayAnim('Down', 2.0*AnimSpeed(2), 0.05);
        else
            PlayAnim('Down', 1.0*AnimSpeed(2), 0.05);
    }
}

function PlaySelect()
{
    PlayAnim('Select',1.0*AnimSpeed(2),0.0);
    Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening);
}

simulated function PlaySelectiveFiring()
{
    local Pawn aPawn;
    local float rnd;
    local Name anim;

    anim = 'Shoot';

    if (bHandToHand)
    {
        rnd = FRand();
        if (rnd < 0.33)
            anim = 'Attack';
        else if (rnd < 0.66)
            anim = 'Attack2';
        else
            anim = 'Attack3';
    }

    if (( Level.NetMode == NM_Standalone ) || ( DeusExPlayer(Owner) == DeusExPlayer(GetPlayerPawn())) )
    {
        if (bAutomatic)
            LoopAnim(anim,1.0*AnimSpeed(1), 0.1);
        else
            PlayAnim(anim,1.0*AnimSpeed(1),0.1);
    }
    else if ( Role == ROLE_Authority )
    {
        for ( aPawn = Level.PawnList; aPawn != None; aPawn = aPawn.nextPawn )
        {
            if ( aPawn.IsA('DeusExPlayer') && ( DeusExPlayer(Owner) != DeusExPlayer(aPawn) ) )
            {
                // If they can't see the weapon, don't bother
                if ( DeusExPlayer(aPawn).FastTrace( DeusExPlayer(aPawn).Location, Location ))
                    DeusExPlayer(aPawn).ClientPlayAnimation( Self, anim, 0.1*AnimSpeed(1), bAutomatic );
            }
        }
    }
}

function float GetDamage()
{
    local float mult;
    // AugCombat increases our damage if hand to hand
    mult = 1.0;
    if (bHandToHand && (DeusExPlayer(Owner) != None))
    {
        mult = DeusExPlayer(Owner).AugmentationSystem.GetAugLevelValue(class'AugCombat');
        if (mult == -1.0)
            mult = 1.0;
    }

    // skill also affects our damage
    // GetWeaponSkill returns 0.0 to -0.7 (max skill/aug)
    mult += -2.0 * GetWeaponSkill();

    if( ! bInstantHit && class != class'WeaponHideAGun' && ProjectileClass != None ) {// PS40 copies its damage to the projectile...
        // ProjectileClass is the currently loaded ammo
        if( class<DeusExProjectile>(ProjectileClass) != None && class<DeusExProjectile>(ProjectileClass).default.bExplodes ) {
            mult *= 2.0 / float(GetNumHits());
        }
        return ProjectileClass.default.Damage * mult;
    }
    return HitDamage * mult;
}

function int GetNumHits()
{
    if( ProjectileClass == class'RocketFixTicks' )
        return 4;
    if( ProjectileClass == class'HECannisterFixTicks' || ProjectileClass == class'PlasmaBoltFixTicks' )
        return 3;

    if( class<DeusExProjectile>(ProjectileClass) != None && class<DeusExProjectile>(ProjectileClass).default.bExplodes )
        return 5;
    if( bInstantHit && AreaOfEffect == AOE_Cone)
        return 5;
    if( ! bInstantHit && AreaOfEffect == AOE_Cone)
        return 3;
    return 1;
}

function Fire(float value)
{
    if (Owner.IsA('DeusExPlayer')) {
        if (bHandToHand) {
            class'DXRStats'.static.AddWeaponSwing(DeusExPlayer(Owner));
        } else if (AmmoLeftInClip()!=0) {
            class'DXRStats'.static.AddShotFired(DeusExPlayer(Owner));
        }
    }
    Super.Fire(value);
}

//mostly copied from DeusExWeapon, but use actual values instead of default values
simulated function bool UpdateInfo(Object winObject)
{
    local PersonaInventoryInfoWindow winInfo;
    local string str;
    local int i, dmg;
    local float mod;
    local bool bHasAmmo;
    local bool bAmmoAvailable;
    local class<DeusExAmmo> ammoClass;
    local Pawn P;
    local Ammo weaponAmmo;
    local int  ammoAmount;

    P = Pawn(Owner);
    if (P == None)
        return False;

    winInfo = PersonaInventoryInfoWindow(winObject);
    if (winInfo == None)
        return False;

    winInfo.SetTitle(itemName);
    winInfo.SetText(msgInfoWeaponStats);
    winInfo.AddLine();

    // Create the ammo buttons.  Start with the AmmoNames[] array,
    // which is used for weapons that can use more than one
    // type of ammo.

    if (AmmoNames[0] != None)
    {
        for (i=0; i<ArrayCount(AmmoNames); i++)
        {
            if (AmmoNames[i] != None)
            {
                // Check to make sure the player has this ammo type
                // *and* that the ammo isn't empty
                weaponAmmo = Ammo(P.FindInventoryType(AmmoNames[i]));

                if (weaponAmmo != None)
                {
                    ammoAmount = weaponAmmo.AmmoAmount;
                    bHasAmmo = (weaponAmmo.AmmoAmount > 0);
                }
                else
                {
                    ammoAmount = 0;
                    bHasAmmo = False;
                }

                winInfo.AddAmmo(AmmoNames[i], bHasAmmo, ammoAmount);
                bAmmoAvailable = True;

                if (AmmoNames[i] == AmmoName)
                {
                    winInfo.SetLoaded(AmmoName);
                    ammoClass = class<DeusExAmmo>(AmmoName);
                }
            }
        }
    }
    else
    {
        // Now peer at the AmmoName variable, but only if the AmmoNames[]
        // array is empty
        if ((AmmoName != class'AmmoNone') && (!bHandToHand) && (ReloadCount != 0))
        {
            weaponAmmo = Ammo(P.FindInventoryType(AmmoName));

            if (weaponAmmo != None)
            {
                ammoAmount = weaponAmmo.AmmoAmount;
                bHasAmmo = (weaponAmmo.AmmoAmount > 0);
            }
            else
            {
                ammoAmount = 0;
                bHasAmmo = False;
            }

            winInfo.AddAmmo(AmmoName, bHasAmmo, ammoAmount);
            winInfo.SetLoaded(AmmoName);
            ammoClass = class<DeusExAmmo>(AmmoName);
            bAmmoAvailable = True;
        }
    }

    // Only draw another line if we actually displayed ammo.
    if (bAmmoAvailable)
        winInfo.AddLine();

    // Ammo loaded
    if ((AmmoName != class'AmmoNone') && (!bHandToHand) && (ReloadCount != 0))
        winInfo.AddAmmoLoadedItem(msgInfoAmmoLoaded, AmmoType.itemName);

    // ammo info
    if ((AmmoName == class'AmmoNone') || bHandToHand || (ReloadCount == 0))
        str = msgInfoNA;
    else
        str = AmmoName.Default.ItemName;
    for (i=0; i<ArrayCount(AmmoNames); i++)
        if ((AmmoNames[i] != None) && (AmmoNames[i] != AmmoName))
            str = str $ "|n" $ AmmoNames[i].Default.ItemName;

    winInfo.AddAmmoTypesItem(msgInfoAmmo, str);

    if( AmmoType != None && AmmoName != None && AmmoName != Class'DeusEx.AmmoNone' )
        winInfo.AddInfoItem("Max Ammo:", AmmoType.MaxAmmo);

    // base damage
    if (Level.NetMode != NM_Standalone)
        dmg = mpHitDamage;
    else
        dmg = HitDamage;

    if( class<DeusExProjectile>(ProjectileClass) != None && class<DeusExProjectile>(ProjectileClass).default.bExplodes )
        dmg *= 2.0 / float(GetNumHits());

    str = String(dmg);
    mod = 1.0 - GetWeaponSkill();
    if (mod != 1.0)
    {
        str = str @ BuildPercentString(mod - 1.0);
        str = str @ "=" @ FormatFloatString(dmg * mod, 1.0);
    }

    winInfo.AddInfoItem(msgInfoDamage, str, (mod != 1.0));

    winInfo.AddInfoItem("Number of Hits:", string(GetNumHits()), true);

    // clip size
    if ((Default.ReloadCount == 0) || bHandToHand)
        str = msgInfoNA;
    else
    {
        if ( Level.NetMode != NM_Standalone )
            str = Default.mpReloadCount @ msgInfoRounds;
        else
            str = Default.ReloadCount @ msgInfoRounds;
    }

    if (HasClipMod())
    {
        str = str @ BuildPercentString(ModReloadCount);
        str = str @ "=" @ ReloadCount @ msgInfoRounds;
    }

    winInfo.AddInfoItem(msgInfoClip, str, HasClipMod());

    // rate of fire
    if ((Default.ReloadCount == 0) || bHandToHand)
    {
        str = msgInfoNA;
    }
    else
    {
        if (bAutomatic)
            str = msgInfoAuto;
        else
            str = msgInfoSingle;

        str = str $ "," @ FormatFloatString(1.0/ShotTime, 0.1) @ msgInfoRoundsPerSec;
    }
    winInfo.AddInfoItem(msgInfoROF, str);

    // reload time
    if ((Default.ReloadCount == 0) || bHandToHand)
        str = msgInfoNA;
    else
    {
        if (Level.NetMode != NM_Standalone )
            str = FormatFloatString(Default.mpReloadTime, 0.1) @ msgTimeUnit;
        else
            str = FormatFloatString(Default.ReloadTime, 0.1) @ msgTimeUnit;
    }

    if (HasReloadMod())
    {
        str = str @ BuildPercentString(ModReloadTime);
        str = str @ "=" @ FormatFloatString(ReloadTime, 0.1) @ msgTimeUnit;
    }

    winInfo.AddInfoItem(msgInfoReload, str, HasReloadMod());

    // recoil
    str = FormatFloatString(Default.recoilStrength, 0.01);
    if (HasRecoilMod())
    {
        str = str @ BuildPercentString(ModRecoilStrength);
        str = str @ "=" @ FormatFloatString(recoilStrength, 0.01);
    }

    winInfo.AddInfoItem(msgInfoRecoil, str, HasRecoilMod());

    // base accuracy (2.0 = 0%, 0.0 = 100%)
    if ( Level.NetMode != NM_Standalone )
    {
        str = Int((2.0 - Default.mpBaseAccuracy)*50.0) $ "%";
        mod = (Default.mpBaseAccuracy - (BaseAccuracy + GetWeaponSkill())) * 0.5;
        if (mod != 0.0)
        {
            str = str @ BuildPercentString(mod);
            str = str @ "=" @ Min(100, Int(100.0*mod+(2.0 - Default.mpBaseAccuracy)*50.0)) $ "%";
        }
    }
    else
    {
        str = Int((2.0 - Default.BaseAccuracy)*50.0) $ "%";
        mod = (Default.BaseAccuracy - (BaseAccuracy + GetWeaponSkill())) * 0.5;
        if (mod != 0.0)
        {
            str = str @ BuildPercentString(mod);
            str = str @ "=" @ Min(100, Int(100.0*mod+(2.0 - Default.BaseAccuracy)*50.0)) $ "%";
        }
    }
    winInfo.AddInfoItem(msgInfoAccuracy, str, (mod != 0.0));

    // accurate range
    if (bHandToHand)
        str = msgInfoNA;
    else
    {
        if ( Level.NetMode != NM_Standalone )
            str = FormatFloatString(Default.mpAccurateRange/16.0, 1.0) @ msgRangeUnit;
        else
            str = FormatFloatString(Default.AccurateRange/16.0, 1.0) @ msgRangeUnit;
    }

    if (HasRangeMod())
    {
        str = str @ BuildPercentString(ModAccurateRange);
        str = str @ "=" @ FormatFloatString(AccurateRange/16.0, 1.0) @ msgRangeUnit;
    }
    winInfo.AddInfoItem(msgInfoAccRange, str, HasRangeMod());

    // max range
    if (bHandToHand)
        str = msgInfoNA;
    else
    {
        if ( Level.NetMode != NM_Standalone )
            str = FormatFloatString(Default.mpMaxRange/16.0, 1.0) @ msgRangeUnit;
        else
            str = FormatFloatString(Default.MaxRange/16.0, 1.0) @ msgRangeUnit;
    }
    winInfo.AddInfoItem(msgInfoMaxRange, str);

    // mass
    winInfo.AddInfoItem(msgInfoMass, FormatFloatString(Default.Mass, 1.0) @ msgMassUnit);

    // laser mod
    if (bCanHaveLaser)
    {
        if (bHasLaser)
            str = msgInfoYes;
        else
            str = msgInfoNo;
    }
    else
    {
        str = msgInfoNA;
    }
    winInfo.AddInfoItem(msgInfoLaser, str, bCanHaveLaser && bHasLaser && (Default.bHasLaser != bHasLaser));

    // scope mod
    if (bCanHaveScope)
    {
        if (bHasScope)
            str = msgInfoYes;
        else
            str = msgInfoNo;
    }
    else
    {
        str = msgInfoNA;
    }
    winInfo.AddInfoItem(msgInfoScope, str, bCanHaveScope && bHasScope && (Default.bHasScope != bHasScope));

    // silencer mod
    if (bCanHaveSilencer)
    {
        if (bHasSilencer)
            str = msgInfoYes;
        else
            str = msgInfoNo;
    }
    else
    {
        str = msgInfoNA;
    }
    winInfo.AddInfoItem(msgInfoSilencer, str, bCanHaveSilencer && bHasSilencer && (Default.bHasSilencer != bHasSilencer));

    // Governing Skill
    winInfo.AddInfoItem(msgInfoSkill, GoverningSkill.default.SkillName);

    winInfo.AddLine();
    winInfo.SetText(Description);

    // If this weapon has ammo info, display it here
    if (ammoClass != None)
    {
        winInfo.AddLine();
        winInfo.AddAmmoDescription(ammoClass.Default.ItemName $ "|n" $ ammoClass.Default.description);
    }

    return True;
}

defaultproperties
{
    blood_mult=0
    anim_speed=1
}
