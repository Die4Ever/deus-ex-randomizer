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
        return 1;// ShotTime of 1 is hardcoded when switching ammo to something with a projectile
    }
    return w.default.ShotTime;
}

//A nice convenient function to ensure we enforce rules consistently across projectile types
simulated function float ProjDamage(float OrigDmg, float ratio, optional float minDmg)
{
    if (minDmg <= 0) minDmg = NORMAL_MIN_DMG; //Minimum 2 damage typically

    //Explosives need to have a higher minimum damage, because their damage gets divided across multiple ticks
    //Explosions deal (dmg x 2)/(num_ticks), where num_ticks is typically 5.

    return Max(ratio * OrigDmg, minDmg);
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
        if(#defined(vmd)) p.default.Damage = ProjDamage(20.0,ratio);
#ifdef injections
        else if(class'MenuChoice_BalanceItems'.static.IsEnabled()) {
            p = class'DXRDart';
            d = p;
            p.default.Damage = ProjDamage(17.0,ratio);
        }
#endif
        else p.default.Damage = ProjDamage(15.0, ratio);
        break;

    case class'#var(prefix)DartFlare':
        #ifdef vmd
        p.default.Damage = ProjDamage(20.0, ratio);
        break;
        #endif
    case class'#var(prefix)DartPoison':
        p.default.Damage = ProjDamage(5.0, ratio);
        break;

    // plasma, don't worry about PS40 because that gets handled in its own class
    case class'#var(prefix)PlasmaBolt':
    case class'PlasmaBoltFixTicks':
        f = 18.0;
        p.default.Damage = ProjDamage(f, ratio, EXPLOSIVE_MIN_DMG);
#ifndef hx
        class'#var(prefix)PlasmaBolt'.default.mpDamage = ProjDamage(f, ratio, 5);
        class'PlasmaBoltFixTicks'.default.mpDamage = ProjDamage(f, ratio, 5);
#endif
        p = class'PlasmaBoltFixTicks';
        d = p;
        p.default.Damage = ProjDamage(f, ratio, EXPLOSIVE_MIN_DMG);
        w.HitDamage = ProjDamage(f, ratio, EXPLOSIVE_MIN_DMG);// write back the weapon damage
        break;

    case class'#var(prefix)Rocket':
        // fix both just in case a normal Rocket is fired somehow?
        p.default.Damage = ProjDamage(300.0, ratio, EXPLOSIVE_MIN_DMG);
        p = class'RocketFixTicks';
        d = p;
    case class'RocketFixTicks':// no break
        p.default.Damage = ProjDamage(300.0, ratio, EXPLOSIVE_MIN_DMG);
        if(class'MenuChoice_BalanceItems'.static.IsDisabled()) {
            p = class'#var(prefix)Rocket';
            d = p;
        }
        break;

    case class'#var(prefix)RocketWP':
        p.default.Damage = ProjDamage(300.0, ratio, EXPLOSIVE_MIN_DMG);
        break;

    case class'#var(prefix)HECannister20mm':
        p.default.Damage = ProjDamage(150.0, ratio, EXPLOSIVE_MIN_DMG);
        p = class'HECannisterFixTicks';
        d = p;
    case class'HECannisterFixTicks':// no break
        // normally the damage should be * 150, but that means a 50% damage rifle could have trouble breaking many doors even with only 3 explosion ticks
        p.default.Damage = ProjDamage(180.0, ratio, EXPLOSIVE_MIN_DMG);
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
        p.default.Damage = ProjDamage(500.0, ratio, EXPLOSIVE_MIN_DMG);
        break;

    case class'#var(prefix)RocketLAW':
        p.default.Damage = ProjDamage(1000.0, ratio, EXPLOSIVE_MIN_DMG);
        break;

    case class'#var(prefix)GreaselSpit':
    case class'#var(prefix)GraySpit':
        p.default.Damage = ProjDamage(8.0, ratio);
        break;

    case class'#var(prefix)RocketMini':
        p.default.Damage = ProjDamage(50.0, ratio, EXPLOSIVE_MIN_DMG);
        break;

    #ifdef vmd
    case class'PlasmaBoltPlague':// Does 1 damage stock. Scaling is irrelevant because it does a unique DOT of explosive damage
        return false;

    case class'PlasmaBoltMini':// (used by PS20): Does 30 damage stock, with smaller radius. Fired in pairs.
        p.default.Damage = ProjDamage(30.0, ratio, EXPLOSIVE_MIN_DMG);
        break;
    case class'RocketEMP':// Does 800 damage base, in WP-esque expanded radius.
        p.default.Damage = ProjDamage(800.0, ratio, EXPLOSIVE_MIN_DMG);
        break;
    #endif

    case class'#var(prefix)GasGrenade':
    case class'#var(prefix)TearGas':
    case class'#var(prefix)RocketRobot':
    case class'#var(prefix)NanoVirusGrenade':
    case class'#var(prefix)EMPGrenade':
        //TODO: ignore these for now
        return false;

    default:
        switch(p.name) { // TODO: move VMD 2.00 classes to above
        #ifdef vmd
        case 'TaserSlug':// Does 24 damage, and is very dart-like.
            p.default.Damage = ProjDamage(24.0, ratio);
            break;
        case 'SierraRocket':// Does 400 damage in a mere 288 radius. Needs lock-on by enemies to be fired. Sticks to player and beeps before detonating.
            p.default.Damage = ProjDamage(400.0, ratio, EXPLOSIVE_MIN_DMG);
            break;
        case 'ObliteratorRocket':// Does 25 damage in 96 blast radius. Fired in clusters.
            p.default.Damage = ProjDamage(25.0, ratio, EXPLOSIVE_MIN_DMG);
            break;
        case 'ObliteratorRocketWP':// Does 25 damage in 256 blast radius. Also fired in clusters.
            p.default.Damage = ProjDamage(25.0, ratio, EXPLOSIVE_MIN_DMG);
            break;
        case 'TartarusFireball':// Does 3 damage with high velocity, high rate of fire, and tiny draw scale.
            p.default.Damage = ProjDamage(3.0, ratio);
            break;
        #endif
        default:
            warning("RandoWeapon("$w$") didn't set damage for projectile "$p$", w.default.HitDamage: "$w.default.HitDamage$", new w.HitDamage: "$w.HitDamage$", p.default.Damage: "$p.default.Damage);
            return false;
        }
        break; // break of default for classes
    }

    return true;
}

#ifndef injections
defaultproperties
{
    bAlwaysTick=True
}
#endif
