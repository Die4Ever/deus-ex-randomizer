class DXRWeapons extends DXRBase transient;
// do not change a weapon's defaults, since we use them in the calculations so this is all safe to be called multiple times
var DXRLoadouts loadouts;

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
    local float min_weapon_dmg, max_weapon_dmg, min_weapon_shottime, max_weapon_shottime, new_damage, default_shottime;
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
    if(w.HitDamage < 2 && w.HitDamage < w.default.HitDamage) {
        if(!silent) l(w $ " w.HitDamage ("$ w.HitDamage $") < 2");
        w.HitDamage = 2;
    }

    if( #var(prefix)WeaponHideAGun(w) == None ) {
        //don't do this for the PS20/PS40 because it shares the PlasmaBolt projectile with the PlasmaRifle in a really dumb way, the PS40 code handles this itself
        //I might move this logic into an injector into DeusExProjectile, maybe in BeginPlay it could check its owner and copy the HitDamage from there?
        RandoProjectile(w, w.ProjectileClass, w.default.ProjectileClass, new_damage);
        for(i=0; i<ArrayCount(w.ProjectileNames); i++) {
            RandoProjectile(w, w.ProjectileNames[i], w.default.ProjectileNames[i], new_damage);
        }
    }

    min_weapon_shottime = float(dxr.flags.settings.min_weapon_shottime) / 100;
    max_weapon_shottime = float(dxr.flags.settings.max_weapon_shottime) / 100;
    default_shottime = GetDefaultShottime(w);
    w.ShotTime = rngrange(default_shottime, min_weapon_shottime, max_weapon_shottime);
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

simulated function bool RandoProjectile(DeusExWeapon w, out class<Projectile> p, out class<Projectile> d, float new_damage)
{
    local float ratio, f;
    if(p == None) return false;

    ratio = new_damage/float(w.default.HitDamage);

    switch(p) {
    case class'#var(prefix)Dart':
        if(#defined(vmd)) p.default.Damage = ratio * 20.0;
        else p.default.Damage = ratio * 15.0;
        p.default.Damage = Max(p.default.Damage, 2);
        break;

    case class'#var(prefix)DartFlare':
        #ifdef vmd
        p.default.Damage = ratio * 20.0;
        break;
        #endif
    case class'#var(prefix)DartPoison':
        p.default.Damage = Max(ratio * 5.0, 2);
        break;

    // plasma, don't worry about PS40 because that gets handled in its own class
    case class'#var(prefix)PlasmaBolt':
    case class'PlasmaBoltFixTicks':
        f = 18.0;
        p.default.Damage = Max(ratio * f, 2);
#ifndef hx
        class'#var(prefix)PlasmaBolt'.default.mpDamage = Max(ratio * f, 2);
        class'PlasmaBoltFixTicks'.default.mpDamage = Max(ratio * f, 2);
#endif
        p = class'PlasmaBoltFixTicks';
        d = p;
        p.default.Damage = Max(ratio * f, 2);
        w.HitDamage = Max(ratio * f, 2);// write back the weapon damage
        break;

    case class'#var(prefix)Rocket':
        // fix both just in case a normal Rocket is fired somehow?
        p.default.Damage = ratio * 300.0;
        p = class'RocketFixTicks';
        d = p;
    case class'RocketFixTicks':// no break
        p.default.Damage = ratio * 300.0;
        if(class'MenuChoice_BalanceItems'.static.IsDisabled()) {
            p = class'#var(prefix)Rocket';
            d = p;
        }
        break;

    case class'#var(prefix)RocketWP':
        p.default.Damage = ratio * 300.0;
        break;

    case class'#var(prefix)HECannister20mm':
        p.default.Damage = ratio * 150.0;
        p = class'HECannisterFixTicks';
        d = p;
    case class'HECannisterFixTicks':// no break
        // normally the damage should be * 150, but that means a 50% damage rifle could have trouble breaking many doors even with only 3 explosion ticks
        p.default.Damage = ratio * 180.0;
        if(class'MenuChoice_BalanceItems'.static.IsDisabled()) {
            p = class'#var(prefix)HECannister20mm';
            d = p;
        }
        break;

    case class'#var(prefix)Shuriken':
    case class'#var(prefix)Fireball':
        p.default.Damage = new_damage;
        break;

    case class'#var(prefix)LAM':
        p.default.Damage = ratio * 500.0;
        break;

    case class'#var(prefix)RocketLAW':
        p.default.Damage = ratio * 1000.0;
        break;

    case class'#var(prefix)GreaselSpit':
    case class'#var(prefix)GraySpit':
        p.default.Damage = ratio * 8.0;
        break;

    case class'#var(prefix)RocketMini':
        p.default.Damage = ratio * 50.0;
        break;

    #ifdef vmd
    case class'PlasmaBoltPlague':// Does 1 damage stock. Scaling is irrelevant because it does a unique DOT of explosive damage
        return false;

    case class'PlasmaBoltMini':// (used by PS20): Does 30 damage stock, with smaller radius. Fired in pairs.
        p.default.Damage = ratio * 30.0;
        break;
    case class'RocketEMP':// Does 800 damage base, in WP-esque expanded radius.
        p.default.Damage = ratio * 800.0;
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
            p.default.Damage = ratio * 24.0;
            break;
        case 'SierraRocket':// Does 400 damage in a mere 288 radius. Needs lock-on by enemies to be fired. Sticks to player and beeps before detonating.
            p.default.Damage = ratio * 400.0;
            break;
        case 'ObliteratorRocket':// Does 25 damage in 96 blast radius. Fired in clusters.
            p.default.Damage = ratio * 25.0;
            break;
        case 'ObliteratorRocketWP':// Does 25 damage in 256 blast radius. Also fired in clusters.
            p.default.Damage = ratio * 25.0;
            break;
        case 'TartarusFireball':// Does 3 damage with high velocity, high rate of fire, and tiny draw scale.
            p.default.Damage = ratio * 3.0;
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
