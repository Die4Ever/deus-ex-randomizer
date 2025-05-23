class DXRWeapon shims DeusExWeapon abstract;

var float RelativeRange;
var float blood_mult;
var float anim_speed;// also adjusted from Ninja JC mode in DXRLoadouts
var float AfterShotTime;// only for description text

var name prev_anim;
var float prev_anim_rate;
var float prev_weapon_skill;

var int WeaponTexLoc[8];

function PostBeginPlay()
{
    local DXRWeapons m;
    Super.PostBeginPlay();

    m = DXRWeapons(class'DXRWeapons'.static.Find(true));
    if(m != None) {
        m.RandoWeapon(self);// RandoWeapon calls UpdateBalance()
    } else {
        UpdateBalance();
    }
}

function PostPostBeginPlay()
{
    Super.PostPostBeginPlay();
    // recalc non travel variables
    MaxRange = default.MaxRange * (ModAccurateRange+1);
}

simulated function UpdateBalance();

function ScopeOn()
{
    local DeusExPlayer player;

    Super.ScopeOn();
    player = DeusExPlayer(Owner);

    ShakeYaw = currentAccuracy * (Rand(1024) - 512);
    ShakePitch = currentAccuracy * (Rand(1024) - 512);
    if (player != None && bZoomed) {
        player.ViewRotation.Yaw += ShakeYaw;
        player.ViewRotation.Pitch += ShakePitch;
    }
}

function ScopeOff()
{
    bWasZoomed = false;
    Super.ScopeOff();
}

function BringUp()
{
    local int texLoc;

    Super.BringUp();

    // don't let NPC geps lock on to targets
    if ((Owner != None) && !Owner.IsA('DeusExPlayer'))
        bCanTrack = False;
    else
        bCanTrack = default.bCanTrack;

    if (class'MenuChoice_AutoLaser'.default.enabled){
        //LaserOn already checks to see if it has a laser, so just call it
        LaserOn();
    }

    for (texLoc=0;texLoc<8;texLoc++){
        if (IsWeaponTexture(texLoc)){
            WeaponTexLoc[texLoc]=1;
        } else {
            WeaponTexLoc[texLoc]=0;
        }
    }

}

//Fix the "Shoot LAWs through narrow walls" glitch
simulated function Vector ComputeProjectileStart(Vector X, Vector Y, Vector Z)
{
    local Vector ProjSpawn, Closest;
    local Vector HitLocation, HitNormal;
    local Actor hit;

    ProjSpawn = Super.ComputeProjectileStart(X,Y,Z);
    Closest = Owner.Location;
    Closest.Z = ProjSpawn.Z;

    if (!bInstantHit && class'MenuChoice_FixGlitches'.default.enabled){
        //Use a full trace (instead of FastTrace) so that we can get the HitLocation
        hit = Trace(HitLocation, HitNormal, ProjSpawn, Closest, False);
        //If you hit something between the owner and where the projectile should have spawned,
        //just spawn the projectile where it hit the thing instead.  Oops!
        if (hit!=None){
            ProjSpawn = HitLocation;
        }
    }

    return ProjSpawn;
}

simulated function Tick(float deltaTime)
{
    local float r, e;

    Super.Tick(deltaTime);

    if (bCanTrack){
        //Update the target message with the correct units
        switch (LockMode)
        {
        case LOCK_Range:
            TargetMessage = msgLockRange @ Int(class'DXRActorsBase'.static.GetRealDistance(TargetRange)) @ class'DXRActorsBase'.static.GetDistanceUnit();
            break;

        case LOCK_Locked:
            TargetMessage = msgLockLocked @ Int(class'DXRActorsBase'.static.GetRealDistance(TargetRange)) @ class'DXRActorsBase'.static.GetDistanceUnit();
            break;
        }
    }

    if(!IsAnimating()) {
        return;
    }

    /*if(AnimSequence != prev_anim && DeusExPlayer(Owner) != None) { // logging to help with issue #1208
        log(self @ Level.TimeSeconds @ AnimSequence);
    }*/

    if(class'MenuChoice_BalanceSkills'.static.IsDisabled()) { // just in case someone plays with randomized shottimes and balance changes disabled?
        if(AnimSequence != prev_anim) {
            prev_anim = AnimSequence;
            r = 1.0;
            if(AnimSequence == 'Shoot' || AnimSequence == 'Attack' || AnimSequence == 'Attack2' || AnimSequence == 'Attack3')
            {
                r = (class'DXRWeapons'.static.GetDefaultShottime(self) / ShotTime);
                r = FClamp(r, 0.4, 1.7);
            }
            prev_anim_rate = AnimRate * r;
        }
    } else if(AnimSequence != prev_anim || GetWeaponSkill() != prev_weapon_skill) {
        prev_anim = AnimSequence;
        r = 1.0;
        e = 1.7;

        if(AnimSequence == 'PlaceBegin' || AnimSequence == 'PlaceEnd')
        {
            if(AnimFrame<0.2)// skip the beginning of the animation
                AnimFrame=0.2;
        }
        else if(AnimSequence == 'Shoot' || AnimSequence == 'Attack' || AnimSequence == 'Attack2' || AnimSequence == 'Attack3')
        {
            r = (class'DXRWeapons'.static.GetDefaultShottime(self) / ShotTime);
            r = FClamp(r, 0.4, 1.7);
            e = 1.0;// these animations don't scale as much with skill
            // PS20/40 should get thrown away more quickly
            if(WeaponHideAGun(self) != None) r *= 1.2;
        }
        else if(AnimSequence == 'Idle1' || AnimSequence == 'Idle2' || AnimSequence == 'Idle3')
        {
            e = 1.0;// these animations don't scale as much with skill
        }
        if(GoverningSkill == Class'SkillDemolition') {
            r *= 1.1;// why are grenades so slow?
            e = 1.9;
        }
        prev_weapon_skill = GetWeaponSkill();
        r *= (anim_speed + -0.2 * prev_weapon_skill) ** e;
        r = FClamp(r, 0.001, 1000);
        prev_anim_rate = AnimRate * r;
    }

    AnimRate = prev_anim_rate;
    OldAnimRate = prev_anim_rate;
}

function bool LoadAmmo(int ammoNum)
{
    local bool ret;
    local DXRWeapons dxrw;

    ret = Super.LoadAmmo(ammoNum);

    // we need to re-randomize the shottime
    dxrw = DXRWeapons(class'DXRWeapons'.static.Find());
    if(dxrw != None) {
        dxrw.RandoWeapon(self);
    }

    return ret;
}

//
// Used to determine if we are near (and facing) a wall for placing LAMs, etc.
// DXRando: longer distance and use EyeHeight instead of BaseEyeHeight, so you can place on floors
simulated function bool NearWallCheck()
{
    local Vector StartTrace, EndTrace, HitLocation, HitNormal;
    local Actor HitActor;

    // Scripted pawns can't place LAMs
    if (ScriptedPawn(Owner) != None)
        return False;

    // trace out one foot in front of the pawn
    StartTrace = Owner.Location;
    if(class'MenuChoice_BalanceItems'.static.IsEnabled()) {
        EndTrace = StartTrace + Vector(Pawn(Owner).ViewRotation) * 50;
        StartTrace.Z += Pawn(Owner).EyeHeight;
        EndTrace.Z += Pawn(Owner).EyeHeight;
    }
    else {
        EndTrace = StartTrace + Vector(Pawn(Owner).ViewRotation) * 32;
        StartTrace.Z += Pawn(Owner).BaseEyeHeight;
        EndTrace.Z += Pawn(Owner).BaseEyeHeight;
    }

    HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace);
    if ((HitActor == Level) || ((HitActor != None) && HitActor.IsA('Mover')))
    {
        placeLocation = HitLocation;
        placeNormal = HitNormal;
        placeMover = Mover(HitActor);

        if (!bNearWall &&
            IsAnimating() &&
            (AnimSequence=='Attack' || AnimSequence=='Attack2' || AnimSequence=='Attack3' ) &&
            (AnimFrame < 0.7) && //Grenade spawns at the 0.7 point (#805) - this is in the AllWeapons.uc file
            (GetStateName() == 'NormalFire'))
        {
            //The throw animation is about to be canceled by a place animation.
            //Ammo gets consumed at the start of the animation, but the projectile is only spawned
            //when the animation completely finishes (Just kidding, #805 proves it spawns at the 0.7 AnimFrame).
            //If it is interrupted, the projectile won't be spawned.  The animation can be easily
            //canceled if you get near a wall and the grenade PlaceBegin and PlaceEnd animations play.
            //We need to catch that to fix issue #519

            AmmoType.AddAmmo(1); //Give the ammo back
            bDestroyOnFinish=False; //Make sure it isn't destroyed afterwards
            if (DeusExPlayer(Owner)!=None){
                DeusExPlayer(Owner).UpdateBeltText(Self);
            }
        }

        return True;
    }

    return False;
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
    if(mult < 0.1) return;

    for (i=0; i < int(mult*1.5); i++)
    {
        v = VRand()*8.0*mult;
        a = this.spawn(class'BloodSpurt',,,HitLocation+HitNormal+v);
        a.DrawScale *= mult * 0.7;
        a = this.spawn(class'BloodDrop',,,HitLocation+HitNormal*4+v);
        a.DrawScale *= mult * 0.7;
    }

    a = this.spawn(class'FleshFragment', None,, HitLocation);
    a.DrawScale = mult * 0.2;
    a.SetCollisionSize(a.CollisionRadius / a.DrawScale, a.CollisionHeight / a.DrawScale);
    a.bFixedRotationDir = True;
    a.RotationRate = RotRand(False);
    a.Velocity = HitNormal * -900.0;
}

function float GetDamage(optional bool ignore_skill, optional bool get_default)
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
    if(ignore_skill)// also ignores aug
        mult = 1.0;

    // ProjectileClass is the currently loaded ammo
    if( class<DeusExProjectile>(ProjectileClass) != None && class<DeusExProjectile>(ProjectileClass).default.bExplodes ) {
        mult *= 2.0 / float(GetNumDamageTicks());
    }

    if(get_default) {
        if(#var(prefix)WeaponHideAGun(self) != None) {
            if(class'MenuChoice_BalanceItems'.static.IsEnabled()) return 100 * mult; // PS40
            else return 25 * mult; // PS20
        }
        // mostly copied from DXRWeapons module
        switch(ProjectileClass) {
        case class'DXRDart':
            return 17.0 * mult;

        case class'#var(prefix)Dart':
            return 15.0 * mult;

        case class'#var(prefix)DartFlare':
        case class'#var(prefix)DartPoison':
            return 5.0 * mult;

        case class'#var(prefix)PlasmaBolt':
        case class'PlasmaBoltFixTicks':
            return 18.0 * mult;

        case class'#var(prefix)Rocket':
        case class'RocketFixTicks':
            return 300.0 * mult;

        case class'#var(prefix)RocketWP':
            return 300.0 * mult;

        case class'#var(prefix)HECannister20mm':
        case class'HECannisterFixTicks':
            // normally the damage should be * 150, but that means a 50% damage rifle could have trouble breaking many doors even with only 3 explosion ticks
            return 180.0 * mult;

        case class'#var(prefix)Shuriken':
        case class'#var(prefix)Fireball':
            return default.HitDamage * mult;

        case class'#var(prefix)LAM':
            return 500.0 * mult;

        case class'#var(prefix)RocketLAW':
            return 1000.0 * mult;

        case class'#var(prefix)GreaselSpit':
        case class'#var(prefix)GraySpit':
            return 8.0 * mult;

        case class'#var(prefix)RocketMini':
            return 50.0 * mult;

        case None:
            return default.HitDamage * mult;
        }
        return ProjectileClass.default.Damage * mult;
    }

    if( class != class'WeaponHideAGun' && ProjectileClass != None ) {// PS40 copies its damage to the projectile...
        return ProjectileClass.default.Damage * mult;
    }

    return HitDamage * mult;
}

function int GetNumDamageTicks()
{
    if( ProjectileClass == class'RocketFixTicks' )
        return 4;
    else if( ProjectileClass == class'HECannisterFixTicks' )
        return 3;
    else if( ProjectileClass == class'PlasmaBoltFixTicks' )
        return 2;
    else if( class<DeusExProjectile>(ProjectileClass) != None && class<DeusExProjectile>(ProjectileClass).default.bExplodes )
        return 5;
    return 1;
}

function int GetTotalNumHits()
{
    return GetNumDamageTicks() * GetNumShots();
}

function int GetNumShots()
{
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

function GetWeaponRanges(out float wMinRange,
                         out float wMaxAccurateRange,
                         out float wMaxRange)
{
    if(AIMaxRange <= 0) {
        Super.GetWeaponRanges(wMinRange, wMaxAccurateRange, wMaxRange);
        return;
    }
    wMinRange         = 0;
    wMaxAccurateRange = AIMaxRange;
    wMaxRange         = AIMaxRange;
}

//mostly copied from DeusExWeapon, but use actual values instead of default values
simulated function bool UpdateInfo(Object winObject)
{
    local PersonaInventoryInfoWindow winInfo;
    local string str;
    local int i, dmg;
    local float mod, TotalShotTime;
    local bool bHasAmmo;
    local bool bAmmoAvailable;
    local class<DeusExAmmo> ammoClass;
    local Pawn P;
    local Ammo weaponAmmo;
    local int  ammoAmount;
    local bool bZeroRando; // used for showing defaults

    P = Pawn(Owner);
    if (P == None)
        return False;

    bZeroRando = class'DXRFlags'.default.bZeroRando;

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

    if( AmmoType != None && AmmoName != None && AmmoName != Class'DeusEx.AmmoNone' ) {
        if(bZeroRando)
            winInfo.AddInfoItem("Max Ammo:", AmmoType.MaxAmmo);
        else
            winInfo.AddInfoItem("Max Ammo:", AmmoType.MaxAmmo $ " (Default: " $ AmmoType.default.MaxAmmo $ ")");
    }

    // base damage
    dmg = GetDamage(true);

    str = String(dmg);
    mod = 1.0 - GetWeaponSkill() * 2.0;
    if (mod != 1.0)
    {
        str = str @ BuildPercentString(mod - 1.0);
        str = str @ "=" @ FormatFloatString(dmg * mod, 1.0);
    }

    winInfo.AddInfoItem(msgInfoDamage, str, (mod != 1.0));

    // default damage
    if(!bZeroRando) {
        dmg = GetDamage(true, true);
        str = " (Default: " $ dmg $ ")";
        winInfo.AddInfoItem("", str);
    }

    winInfo.AddInfoItem("Number of Hits:", string(GetTotalNumHits()), true);

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
    // RANDO: Always show rate of fire
    TotalShotTime = ShotTime + AfterShotTime;
    if ((Default.ReloadCount == 0) || bHandToHand)
    {
        //str = msgInfoNA;
        str = FormatFloatString(1.0/TotalShotTime, 0.1) $ "/SEC";
    }
    else
    {
        if (bAutomatic)
            str = msgInfoAuto;
        else
            str = msgInfoSingle;

        str = str $ "," @ FormatFloatString(1.0/TotalShotTime, 0.1) @ msgInfoRoundsPerSec;
    }
    winInfo.AddInfoItem(msgInfoROF, str);

    // default rate of fire
    TotalShotTime = default.ShotTime + default.AfterShotTime;
    if (!bZeroRando && Default.ReloadCount != 0 && !bHandToHand)
    {
        str = FormatFloatString(1.0/TotalShotTime, 0.1) @ msgInfoRoundsPerSec $ ")";
        winInfo.AddInfoItem("", " (Default: " $ str);
    }

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
            str = FormatFloatString(class'DXRActorsBase'.static.GetRealDistance(Default.mpAccurateRange), 1.0) @ Caps(class'DXRActorsBase'.static.GetDistanceUnit());
        else
            str = FormatFloatString(class'DXRActorsBase'.static.GetRealDistance(Default.AccurateRange), 1.0) @ Caps(class'DXRActorsBase'.static.GetDistanceUnit());
    }

    if (HasRangeMod())
    {
        str = str @ BuildPercentString(ModAccurateRange);
        str = str @ "|n    =" @ FormatFloatString(class'DXRActorsBase'.static.GetRealDistance(AccurateRange), 1.0) @ Caps(class'DXRActorsBase'.static.GetDistanceUnit());
    }
    winInfo.AddInfoItem(msgInfoAccRange, str, HasRangeMod());

    // max range
    if (bHandToHand)
        str = msgInfoNA;
    else
    {
        if ( Level.NetMode != NM_Standalone )
            str = FormatFloatString(class'DXRActorsBase'.static.GetRealDistance(Default.mpMaxRange), 1.0) @ Caps(class'DXRActorsBase'.static.GetDistanceUnit());
        else
            str = FormatFloatString(class'DXRActorsBase'.static.GetRealDistance(Default.MaxRange), 1.0) @ Caps(class'DXRActorsBase'.static.GetDistanceUnit());
    }
    if (HasRangeMod())
    {
        str = str @ BuildPercentString(ModAccurateRange);
        str = str @ "|n    =" @ FormatFloatString(class'DXRActorsBase'.static.GetRealDistance(MaxRange), 1.0) @ Caps(class'DXRActorsBase'.static.GetDistanceUnit());
    }
    winInfo.AddInfoItem(msgInfoMaxRange, str, HasRangeMod());

    // mass - RANDO: Show mass in the appropriate unit
    winInfo.AddInfoItem(msgInfoMass, FormatFloatString(class'DXRActorsBase'.static.GetRealMass(Default.Mass), 1.0) @ Caps(class'DXRActorsBase'.static.GetMassUnit()));

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

//
// TraceFire DXRando: just wanted to do the RelativeRange fix like VMD does, and fix the unscoped accuracy penalty
//
simulated function TraceFire( float Accuracy )
{
    local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
    local Rotator rot;
    local actor Other;
    local float dist, alpha, degrade;
    local int i, numSlugs;
    local float volume, radius;

    // make noise if we are not silenced
    if (!bHasSilencer && !bHandToHand)
    {
        GetAIVolume(volume, radius);
        Owner.AISendEvent('WeaponFire', EAITYPE_Audio, volume, radius);
        Owner.AISendEvent('LoudNoise', EAITYPE_Audio, volume, radius);
        if (!Owner.IsA('PlayerPawn'))
            Owner.AISendEvent('Distress', EAITYPE_Audio, volume, radius);
    }

    GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
    StartTrace = ComputeProjectileStart(X, Y, Z);
    AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2.75*AimError, False, False);

    // check to see if we are a shotgun-type weapon
    if (AreaOfEffect == AOE_Cone)
        numSlugs = 5;
    else
        numSlugs = 1;

    // DXRando: fix the unscoped accuracy penalty
    // if there is a scope, but the player isn't using it, decrease the accuracy
    // so there is an advantage to using the scope
    //if (bHasScope && !bZoomed)
        //Accuracy += 0.2;
    // if the laser sight is on, make this shot dead on
    // also, if the scope is on, zero the accuracy so the shake makes the shot inaccurate
    //else if (bLasing || bZoomed)
    if (bLasing || bZoomed)
        Accuracy = 0.0;

    if(!bHandToHand && bInstantHit && bPenetrating) Accuracy *= MaxRange / RelativeRange;// DXRando: copied from VMD

    for (i=0; i<numSlugs; i++)
    {
      // If we have multiple slugs, then lower our accuracy a bit after the first slug so the slugs DON'T all go to the same place
      if ((i > 0) /*&& (Level.NetMode != NM_Standalone)*/ && !(bHandToHand))
         if (Accuracy < MinSpreadAcc)
            Accuracy = MinSpreadAcc;

      // Let handtohand weapons have a better swing
      if ((bHandToHand) && (NumSlugs > 1) && (Level.NetMode != NM_Standalone))
      {
         StartTrace = ComputeProjectileStart(X,Y,Z);
         StartTrace = StartTrace + (numSlugs/2 - i) * SwingOffset;
      }

      EndTrace = StartTrace + Accuracy * (FRand()-0.5)*Y*1000 + Accuracy * (FRand()-0.5)*Z*1000 ;
      EndTrace += (FMax(1024.0, MaxRange) * vector(AdjustedAim));

      Other = Pawn(Owner).TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);

        // randomly draw a tracer for relevant ammo types
        // don't draw tracers if we're zoomed in with a scope - looks stupid
      // DEUS_EX AMSD In multiplayer, draw tracers all the time.
        if ( ((Level.NetMode == NM_Standalone) && (!bZoomed && (numSlugs == 1) && (FRand() < 0.5))) ||
           ((Level.NetMode != NM_Standalone) && (Role == ROLE_Authority) && (numSlugs == 1)) )
        {
            if ((AmmoName == Class'Ammo10mm') || (AmmoName == Class'Ammo3006') ||
                (AmmoName == Class'Ammo762mm'))
            {
                if (VSize(HitLocation - StartTrace) > 250)
                {
                    rot = Rotator(EndTrace - StartTrace);
               if ((Level.NetMode != NM_Standalone) && (Self.IsA('WeaponRifle')))
                  Spawn(class'SniperTracer',,, StartTrace + 96 * Vector(rot), rot);
               else
                  Spawn(class'Tracer',,, StartTrace + 96 * Vector(rot), rot);
                }
            }
        }

        // check our range
        dist = Abs(VSize(HitLocation - Owner.Location));

        if (dist <= AccurateRange)      // we hit just fine
            ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);
        else if (dist <= MaxRange)
        {
            // simulate gravity by lowering the bullet's hit point
            // based on the owner's distance from the ground
            alpha = (dist - AccurateRange) / (MaxRange - AccurateRange);
            degrade = 0.5 * Square(alpha);
            HitLocation.Z += degrade * (Owner.Location.Z - Owner.CollisionHeight);
            ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);
        }
    }

    // otherwise we don't hit the target at all
}

//Fix for "Janky Breaking Movers" (Issue #457)
simulated function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
    local DeusExPlayer dxPlayer;

    //Redirect hits against the level when you're highlighting a mover
    //Hack borrowed from WCCC
    if (Other == Level){
        dxPlayer = DeusExPlayer(Owner);
        if (dxPlayer != None && Mover(dxPlayer.FrobTarget) != None){
            Other = dxPlayer.FrobTarget;
        }
    }
    Super.ProcessTraceHit(Other,HitLocation,HitNormal,X,Y,Z);
}

simulated function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
    local float oldCurrentAccuracy;
    local Projectile p;

    oldCurrentAccuracy = currentAccuracy;
    if(bLasing) {
        if (AreaOfEffect == AOE_Cone)
            currentAccuracy = FMin(currentAccuracy, 0.1);
        else
            currentAccuracy = 0;
    }
    p = Super.ProjectileFire(ProjClass, ProjSpeed, bWarn);
    currentAccuracy = oldCurrentAccuracy;// just make sure we don't accidentally affect anything else
    return p;
}

function TravelPostAccept()
{
    Super.TravelPostAccept();

    if (IsA('WeaponPlasmaRifle')){
        FireSound = Default.FireSound;
    }
}

simulated function bool IsWeaponTexture(int i)
{
    local Texture thisTex;

    thisTex = GetMeshTexture(i);
    if (thisTex==None){
        return false;
    } else if (InStr(string(thisTex),"MaskTex")!=-1){
        return false;
    } else if (InStr(string(thisTex),"WeaponHandsTex")!=-1){
        return false;
    } else if (InStr(string(thisTex),"SFX")!=-1){
        return false;
    } else if (InStr(string(thisTex),"MapTex")!=-1){
        return false;
    } else {
        return true;
    }
}

simulated event RenderOverlays( canvas Canvas )
{
    local Texture origTex[8];
    local int texLoc;
    Super.RenderOverlays(Canvas);

    if(class'MenuChoice_BalanceEtc'.static.IsDisabled()) return;
    //Draw an indication that the weapon still has a shot in progress
    //if (bFiring && !IsAnimating() && PlayerPawn(Owner)!=None){
    //bPointing seems to be updated basically the same as bFiring, except it works for melee as well
    if (GetStateName()=='NormalFire' && !IsAnimating() && !bAutomatic && PlayerPawn(Owner)!=None){
        ScaleGlow=0.1;
        Style = STY_Translucent;

        for (texLoc=0;texLoc<8;texLoc++){
            origTex[texLoc] = MultiSkins[texLoc];
            if (WeaponTexLoc[texLoc]==1){
                MultiSkins[texLoc]=Texture'Effects.Laser.LaserBeam1';
            }
        }

        Canvas.DrawActor(self, false);

        for (texLoc=0;texLoc<8;texLoc++){
            MultiSkins[texLoc]=origTex[texLoc];
        }

        Style = STY_Normal;
        ScaleGlow=1.0;
    }
}

function bool HandlePickupQuery(Inventory Item)
{
    local DeusExWeapon W;
    local DeusExPlayer player;
    local class<Ammo> defAmmoClass;
    local Ammo defAmmo,newAmmo;
    local int ammoToAdd,ammoRemaining;
    local bool ammoBanned;
    local DXRLoadouts loadout;

    W = DeusExWeapon(Item);
    player = DeusExPlayer(Owner);

    if (w!=None && player!=None && Item.Class == Class)
    {
        if (!( (w.bWeaponStay && (Level.NetMode == NM_Standalone)) && (!w.bHeldItem || w.bTossedOut)))
        {
            if ( AmmoType != None )
            {
                if ( AmmoNames[0] == None ){
                    defAmmoClass = AmmoName;
                }else{
                    defAmmoClass = AmmoNames[0];
                }

                loadout = DXRLoadouts(class'DXRLoadouts'.static.Find());
                ammoBanned=False;
                if (loadout!=None){
                    ammoBanned = loadout.is_banned(defAmmoClass);
                }

                if (!ammoBanned){
                    defAmmo = Ammo(player.FindInventoryType(defAmmoClass));
                    if(defAmmo!=None){
                        ammoToAdd = w.PickUpAmmoCount;
                        ammoRemaining=0;
                        if ((ammoToAdd + defAmmo.AmmoAmount) > defAmmo.MaxAmmo){
                            ammoRemaining = (ammoToAdd + defAmmo.AmmoAmount) - defAmmo.MaxAmmo;
                            ammoToAdd = ammoToAdd - ammoRemaining;
                        }

                        w.PickUpAmmoCount = ammoToAdd;
                        if (ammoRemaining>0){
                            if(defAmmoClass.Default.Mesh!=LodMesh'DeusExItems.TestBox'){
                                //Weapons with normal ammo that exists
                                newAmmo = Spawn(defAmmoClass,,,w.Location,w.Rotation);
                                newAmmo.ammoAmount = ammoRemaining;
                                newAmmo.Velocity = Velocity + VRand() * 160;
                            } else {
                                w.PickUpAmmoCount = ammoRemaining;
                                defAmmo.AddAmmo(ammoToAdd);
                                return True;
                            }
                        }
                    }
                } else {
                    w.PickUpAmmoCount = 0; //Remove all the ammo
                }
            }
        }
    }

    return Super.HandlePickupQuery(Item);
}

function DropFrom(vector StartLocation)
{
    local int oldAmmo;
    if(PlayerPawn(Owner) == None) {
        oldAmmo = PickupAmmoCount;
    }
    Super.DropFrom(StartLocation);
    if(oldAmmo > 0) {
        PickupAmmoCount = oldAmmo;
    }
}

// vanilla MinSpreadAcc is 0.25, but only used in multiplayer, so really it normally acts like 0
// we're mainly turning on MinSpreadAcc for singleplayer because of the shotguns, so we want a minimal change here of 0.05
defaultproperties
{
    blood_mult=0
    anim_speed=1
    RelativeRange=3750.0
    MinSpreadAcc=0.05
}
