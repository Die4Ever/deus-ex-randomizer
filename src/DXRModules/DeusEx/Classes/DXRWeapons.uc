class DXRWeapons extends DXRBase transient;
// do not change a weapon's defaults, since we use them in the calculations so this is all safe to be called multiple times
var DXRLoadouts loadouts;

const NORMAL_MIN_DMG = 2;
const EXPLOSIVE_MIN_DMG = 5;

simulated function PlayerAnyEntry(#var(PlayerPawn) p)
{
    local DeusExWeapon w;
    Super.PlayerAnyEntry(p);

    loadouts = DXRLoadouts(dxr.FindModule(class'DXRLoadouts'));

    foreach AllActors(class'DeusExWeapon', w) {
        RandoWeapon(w);
    }
    if(!#defined(injections)) SetTimer(1, true);
}

simulated function Timer()
{
    local DeusExWeapon w;
    Super.Timer();
    if( dxr == None ) return;

    foreach AllActors(class'DeusExWeapon', w) {
        RandoWeapon(w, true);
    }
}

simulated function RandoWeapon(DeusExWeapon w, optional bool silent)
{
    local int oldseed, i;
    local float min_weapon_dmg, max_weapon_dmg, min_weapon_shottime, max_weapon_shottime, new_damage, default_shottime, f;
    if( dxr == None ) return;
#ifdef vanilla
    DXRWeapon(w).UpdateBalance();
#endif

    oldseed = SetGlobalSeed("RandoWeapon " $ w.class.name);

    if( loadouts != None ) loadouts.AdjustWeapon(w);
    if(WeaponRubberBaton(w) != None) return;

    min_weapon_dmg = float(dxr.flags.settings.min_weapon_dmg) / 100;
    max_weapon_dmg = float(dxr.flags.settings.max_weapon_dmg) / 100;

    new_damage = w.default.HitDamage;
#ifdef injections
    if(WeaponHideAGun(w) != None && class'MenuChoice_BalanceItems'.static.IsEnabled()) {
        new_damage = WeaponHideAGun(w).UpgradeToPS40();
    }
#endif
    new_damage = rngrange(new_damage, min_weapon_dmg, max_weapon_dmg);
    w.HitDamage = int(new_damage + 0.5);
    if(w.HitDamage < NORMAL_MIN_DMG && w.HitDamage < w.default.HitDamage) {
        if(!silent) l(w $ " w.HitDamage ("$ w.HitDamage $") < 2");
        w.HitDamage = NORMAL_MIN_DMG;
    }

    if( #var(prefix)WeaponHideAGun(w) == None ) {
        //don't do this for the PS20/PS40 because it shares the PlasmaBolt projectile with the PlasmaRifle in a really dumb way, the PS40 code handles this itself
        //I might move this logic into an injector into DeusExProjectile, maybe in BeginPlay it could check its owner and copy the HitDamage from there?
        RandoProjectile(w, w.ProjectileClass, w.ProjectileClass, new_damage);
        RandoProjectile(w, w.default.ProjectileClass, w.default.ProjectileClass, new_damage); // sometimes the current value and the default value mismatch
        for(i=0; i<ArrayCount(w.ProjectileNames); i++) {
            RandoProjectile(w, w.ProjectileNames[i], w.default.ProjectileNames[i], new_damage); // the current value is always the same as the default
        }
    }

    min_weapon_shottime = float(dxr.flags.settings.min_weapon_shottime) / 100;
    max_weapon_shottime = float(dxr.flags.settings.max_weapon_shottime) / 100;
    default_shottime = GetDefaultShottime(w);
    f = rngrange(1, min_weapon_shottime, max_weapon_shottime);
    w.ShotTime = f * default_shottime;
#ifdef injections
    DXRWeapon(w).AfterShotTime = f * DXRWeapon(w).default.AfterShotTime;
#endif
    if(!silent) l(w $ " w.HitDamage="$ w.HitDamage $ ", ShotTime=" $ w.ShotTime);
    /*f = w.default.ReloadTime * (rngf()+0.5);
    w.ReloadTime = f;
    f = float(w.default.MaxRange) * (rngf()+0.5);
    w.MaxRange = int(f);
    f = float(w.default.AccurateRange) * (rngf()+0.5);
    w.AccurateRange = int(f);
    f = w.default.BaseAccuracy * (rngf()+0.5);
    w.BaseAccuracy = f;*/
    ReapplySeed(oldseed);
}

static function float GetDefaultShottime(DeusExWeapon w) {
    // HACK: changing ammo types is awkward because there's no array for ShotTime, technically a nerf to the crossbow?
    if(/*w.default.ProjectileClass == None &&*/ w.ProjectileClass != None && (w.AmmoNames[1] != None || w.AmmoNames[2] != None)) {
        #ifdef gmdx
            //GMDX actually sets the shot time to the default of the weapon when switching!  Surprising!
            return w.Default.ShotTime;
        #else
            return 1;// ShotTime of 1 is hardcoded when switching ammo to something with a projectile
        #endif
    }
    return w.default.ShotTime;
}

//A nice convenient function to ensure we enforce rules consistently across projectile types
simulated function float ProjDamage(class<Projectile> p, float ratio, optional float minDmg)
{
    return _ProjDamage(GetDefaultProjDamage(p),ratio,minDmg);
}

simulated function float _ProjDamage(float OrigDmg, float ratio, optional float minDmg)
{
    if (minDmg <= 0) minDmg = NORMAL_MIN_DMG; //Minimum 2 damage typically

    //Explosives need to have a higher minimum damage, because their damage gets divided across multiple ticks
    //Explosions deal (dmg x 2)/(num_ticks), where num_ticks is typically 5.

    return FMax(ratio * OrigDmg, minDmg);
}

//This sucks ass, but we already hardcoded these before, and we modify the default values
//This is at least a central spot where the determination of what damage to use doesn't
//get mixed with other logic
simulated function float GetDefaultProjDamage(class<Projectile> p)
{
    switch(p)
    {
#ifdef injections
    case class'DXRDart':
#endif
    case class'#var(prefix)Dart':
        if (#defined(vmd)){
            return 20.0;
        } else if (#defined(revision)){
            if (UsingShifterOrBioMod()){
                return 18.0;
            } else {
                return 10.0;
            }
        } else if (#defined(gmdx)){
            return 20.0;
        } else if(class'MenuChoice_BalanceItems'.static.IsEnabled()){
            return 17.0;
        } else {
            return 15.0;
        }

    case class'#var(prefix)DartFlare':
        if (#defined(vmd)){
            return 20.0;
        } else if (#defined(revision)){
            if (UsingShifterOrBioMod()){
                return 2.5;
            } else {
                return 10.0;
            }
        } else if (#defined(gmdx)){
            return 7.0;
        } else {
            return 5.0;
        }

    case class'#var(prefix)DartPoison':
        if (#defined(gmdx)){
            return 13.0;
        } else {
            return 5.0;
        }

    case class'#var(prefix)PlasmaBolt':
    case class'PlasmaBoltFixTicks':
        if (#defined(vmd)){
            return 25.0;
        } else if (#defined(revision)){
            if (UsingShifterOrBioMod()){
                return 40.0;
            } else {
                return 20.0;
            }
        } else if (#defined(gmdx)){
            return 20.0;
        } else {
            //This is rebalanced from the vanilla 8 damage (when bugged, 40 was intended)
            return 18.0;
        }

#ifdef gmdxnotae
    case class'GMDXRocket':
#endif
    case class'#var(prefix)Rocket':
    // fix both just in case a normal Rocket is fired somehow (like in zero rando)
    case class'RocketFixTicks':// no break
        if (#defined(gmdx)){
            return 200.0;
        } else {
            return 300.0;
        }

#ifdef gmdxnotae
    case class'GMDXRocketWP':
#endif
    case class'#var(prefix)RocketWP':
        if (#defined(gmdx)){
            return 60.0;
        } else {
            return 300.0;
        }

    case class'#var(prefix)HECannister20mm':
        if (#defined(gmdx)){
            return 200.0;
        } else {
            return 150.0;
        }

    case class'HECannisterFixTicks':
        // normally the damage should be * 150, but that means a 50% damage rifle could have trouble breaking many doors even with only 3 explosion ticks
        if (#defined(gmdx)){
            //Just keep the increased GMDX damage
            return 200.0;
        } else {
            return 180.0;
        }

    case class'#var(prefix)LAM':
        if (#defined(gmdx)){
            return 400.0;
        } else if (#defined(vmd2)){
            return 200.0;
        } else {
            return 500.0;
        }

    case class'#var(prefix)RocketLAW':
        //Everyone agrees!
        return 1000.0;

    case class'#var(prefix)GreaselSpit':
        //Oh my god, even more agreement!
        return 8.0;

    case class'#var(prefix)GraySpit':
        //Chaos reigns once again
        if (#defined(gmdx)){
            return 20.0;
        } else {
            return 8.0;
        }

    case class'#var(prefix)RocketMini':
        if (#defined(gmdx)){
            return 60.0;
        } else {
            return 50.0;
        }

#ifdef vmd
    case class'PlasmaBoltMini':// (used by PS20): Does 30 damage stock, with smaller radius. Fired in pairs.
        return 30.0;

    case class'RocketEMP':// Does 800 damage base, in WP-esque expanded radius.
        return 800.0;
#endif

#ifdef vmd2
    case class'TaserSlug':
        return 24.0;

    case class'SierraRocket':
        return 400.0;

    case class'ObliteratorRocket':
        return 25.0;

    case class'ObliteratorRocketWP':
        return 25.0;

    case class'TartarusFireball':
        return 3.0;
#endif

#ifdef gmdx

    case class'DartTaser':
        return 15.0;

#endif

    }

    err("GetDefProjDamage() could not find projectile "$p);
    return p.Default.Damage;
}

simulated function bool RandoProjectile(DeusExWeapon w, out class<Projectile> p, out class<Projectile> d, float new_damage)
{
    local float ratio, f;
    if(p == None) return false;

    ratio = new_damage/float(w.default.HitDamage);

    switch(p) {
#ifdef injections
    case class'DXRDart':
#endif
    case class'#var(prefix)Dart':
        if(#defined(vmd)) p.default.Damage = ProjDamage(p,ratio);
#ifdef injections
        else if(class'MenuChoice_BalanceItems'.static.IsEnabled()) {
            p = class'DXRDart';
            d = p;
            p.default.Damage = ProjDamage(p,ratio);
        }
#endif
        else p.default.Damage = ProjDamage(p, ratio);
        break;

    case class'#var(prefix)DartFlare':
        p.default.Damage = ProjDamage(p, ratio);
        break;
    case class'#var(prefix)DartPoison':
        p.default.Damage = ProjDamage(p, ratio);
        break;

    // plasma, don't worry about PS40 because that gets handled in its own class
    case class'#var(prefix)PlasmaBolt':
    case class'PlasmaBoltFixTicks':
        f = 18.0;
        p.default.Damage = ProjDamage(p, ratio, EXPLOSIVE_MIN_DMG);
#ifndef hx
        class'#var(prefix)PlasmaBolt'.default.mpDamage = ProjDamage(class'#var(prefix)PlasmaBolt', ratio, 5);
        class'PlasmaBoltFixTicks'.default.mpDamage = ProjDamage(class'PlasmaBoltFixTicks', ratio, 5);
#endif
        p = class'PlasmaBoltFixTicks';
        d = p;
        p.default.Damage = ProjDamage(p, ratio, EXPLOSIVE_MIN_DMG);
        w.HitDamage = ProjDamage(p, ratio, EXPLOSIVE_MIN_DMG);// write back the weapon damage
        break;

#ifdef gmdxnotae
    case class'GMDXRocket':
        //Gets fired when BalanceItems is Disabled in GMDX
        //This version of the rocket fixes scope issues in GMDX
#endif
    case class'#var(prefix)Rocket':
        // Gets fired when BalanceItems is Disabled (outside of GMDX)
        p.default.Damage = ProjDamage(p, ratio, EXPLOSIVE_MIN_DMG);
        p = class'RocketFixTicks';
        d = p;
    case class'RocketFixTicks':// no break
        p.default.Damage = ProjDamage(p, ratio, EXPLOSIVE_MIN_DMG);
        if(class'MenuChoice_BalanceItems'.static.IsDisabled()) {
            #ifdef gmdxnotae
            p = class'GMDXRocket';
            #else
            p = class'#var(prefix)Rocket';
            #endif
            d = p;
        }
        break;

    case class'#var(prefix)RocketWP':
        p.default.Damage = ProjDamage(p, ratio, EXPLOSIVE_MIN_DMG);
#ifdef gmdxnotae
        p = class'GMDXRocketWP';
        d = p;
    case class'GMDXRocketWP':
        //This version of the rocket fixes scope issues in GMDX
        p.default.Damage = ProjDamage(p, ratio, EXPLOSIVE_MIN_DMG);
#endif
        break;

    case class'#var(prefix)HECannister20mm':
        p.default.Damage = ProjDamage(p, ratio, EXPLOSIVE_MIN_DMG);
        p = class'HECannisterFixTicks';
        d = p;
    case class'HECannisterFixTicks':// no break
        // normally the damage should be * 150, but that means a 50% damage rifle could have trouble breaking many doors even with only 3 explosion ticks
        p.default.Damage = ProjDamage(p, ratio, EXPLOSIVE_MIN_DMG);
        if(class'MenuChoice_BalanceItems'.static.IsDisabled()) {
            p = class'#var(prefix)HECannister20mm';
            d = p;
        }
        break;

    case class'#var(prefix)Shuriken':
    case class'#var(prefix)Fireball':
        //Copy the damage straight across, with a minimum 2
        p.default.Damage = Max(new_damage,NORMAL_MIN_DMG);
        break;

    case class'#var(prefix)LAM':
        p.default.Damage = ProjDamage(p, ratio, EXPLOSIVE_MIN_DMG);
        break;

    case class'#var(prefix)RocketLAW':
        p.default.Damage = ProjDamage(p, ratio, EXPLOSIVE_MIN_DMG);
        break;

    case class'#var(prefix)GreaselSpit':
    case class'#var(prefix)GraySpit':
        p.default.Damage = ProjDamage(p, ratio);
        break;

    case class'#var(prefix)RocketMini':
        p.default.Damage = ProjDamage(p, ratio, EXPLOSIVE_MIN_DMG);
        break;

    #ifdef vmd
    case class'PlasmaBoltPlague':// Does 1 damage stock. Scaling is irrelevant because it does a unique DOT of explosive damage
        return false;

    case class'PlasmaBoltMini':// (used by PS20): Does 30 damage stock, with smaller radius. Fired in pairs.
        p.default.Damage = ProjDamage(p, ratio, EXPLOSIVE_MIN_DMG);
        break;
    case class'RocketEMP':// Does 800 damage base, in WP-esque expanded radius.
        p.default.Damage = ProjDamage(p, ratio, EXPLOSIVE_MIN_DMG);
        break;
    #endif

    #ifdef vmd2
    case class'TaserSlug':
        p.default.Damage = ProjDamage(p, ratio);
        break;

    case class'SierraRocket':
        p.default.Damage = ProjDamage(p, ratio, EXPLOSIVE_MIN_DMG);
        break;

    case class'ObliteratorRocket':
        p.default.Damage = ProjDamage(p, ratio, EXPLOSIVE_MIN_DMG);
        break;

    case class'ObliteratorRocketWP':
        p.default.Damage = ProjDamage(p, ratio, EXPLOSIVE_MIN_DMG);
        break;

    case class'TartarusFireball':
        p.default.Damage = ProjDamage(p, ratio);
        break;
    #endif

    #ifdef gmdx
    case class'DartTaser':
        p.default.Damage = ProjDamage(p, ratio);
        break;

    case class'RubberBullet':
        //Don't try to randomize these, they do hardcoded damage on Bump
        return false;
    #endif

    case class'#var(prefix)GasGrenade':
    case class'#var(prefix)TearGas':
    case class'#var(prefix)RocketRobot':
    case class'#var(prefix)NanoVirusGrenade':
    case class'#var(prefix)EMPGrenade':
        //TODO: ignore these for now
        return false;

    default:
        warning("RandoProjectile("$w$") didn't set damage for projectile "$p$", w.default.HitDamage: "$w.default.HitDamage$", new w.HitDamage: "$w.HitDamage$", p.default.Damage: "$p.default.Damage);
        return false;
        break;
    }

    return true;
}

#ifndef injections
defaultproperties
{
    bAlwaysTick=True
}
#endif
