class DXRWeapons extends DXRBase;
// do not change a weapon's defaults, since we use them in the calculations so this is all safe to be called multiple times
var DXRLoadouts loadouts;

function CheckConfig()
{
    if( ConfigOlderThan(1,6,0,1) ) {
    }
    Super.CheckConfig();
}

simulated function AnyEntry()
{
    local DeusExWeapon w;
    Super.AnyEntry();

    loadouts = DXRLoadouts(dxr.FindModule(class'DXRLoadouts'));

    foreach AllActors(class'DeusExWeapon', w) {
        RandoWeapon(w);
    }
}

simulated function PlayerAnyEntry(#var(PlayerPawn) p)
{
    Super.PlayerAnyEntry(p);
    AnyEntry();
}

simulated function RandoWeapon(DeusExWeapon w)
{
    local int oldseed, i;
    local float min_weapon_dmg, max_weapon_dmg, min_weapon_shottime, max_weapon_shottime, new_damage;
    if( dxr == None ) return;
    oldseed = SetGlobalSeed("RandoWeapon " $ w.class.name);

    if( loadouts != None ) loadouts.AdjustWeapon(w);

    min_weapon_dmg = float(dxr.flags.settings.min_weapon_dmg) / 100;
    max_weapon_dmg = float(dxr.flags.settings.max_weapon_dmg) / 100;
    new_damage = rngrange(float(w.default.HitDamage), min_weapon_dmg, max_weapon_dmg);
    w.HitDamage = int(new_damage + 0.5);
    if(w.HitDamage < 2 && w.HitDamage < w.default.HitDamage) {
        info(w $ " w.HitDamage ("$ w.HitDamage $") < 2");
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
    w.ShotTime = rngrange(w.default.ShotTime, min_weapon_shottime, max_weapon_shottime);
    l(w $ " w.HitDamage: "$ w.HitDamage $ ", ShotTime: " $ w.ShotTime);
    /*f = w.default.ReloadTime * (rngf()+0.5);
    w.ReloadTime = f;
    f = float(w.default.MaxRange) * (rngf()+0.5);
    w.MaxRange = int(f);
    f = float(w.default.AccurateRange) * (rngf()+0.5);
    w.AccurateRange = int(f);
    f = w.default.BaseAccuracy * (rngf()+0.5);
    w.BaseAccuracy = f;*/
    dxr.SetSeed(oldseed);
}

simulated function RandoProjectile(DeusExWeapon w, out class<Projectile> p, out class<Projectile> d, float new_damage)
{
    local float ratio;
    if(p == None) return;

    ratio = new_damage/float(w.default.HitDamage);

    switch(p) {
    case class'#var(prefix)Dart':
        p.default.Damage = ratio * 15.0;
        break;

    case class'#var(prefix)DartFlare':
    case class'#var(prefix)DartPoison':
        p.default.Damage = ratio * 5.0;
        break;

    case class'#var(prefix)PlasmaBolt':
        p.default.Damage = ratio * 10.0;
#ifndef hx
        class<#var(prefix)PlasmaBolt>(p).default.mpDamage = ratio * 10.0;
#endif
        w.HitDamage = ratio * 10.0;
        p = class'PlasmaBoltFixTicks';
        d = p;
    case class'PlasmaBoltFixTicks':// no break
        p.default.Damage = ratio * 10.0;
#ifndef hx
        class<PlasmaBoltFixTicks>(p).default.mpDamage = ratio * 10.0;
#endif
        w.HitDamage = ratio * 10.0;
        break;

    case class'#var(prefix)Rocket':
        // fix both just in case a normal Rocket is fired somehow?
        p.default.Damage = ratio * 300.0;
        p = class'RocketFixTicks';
        d = p;
    case class'RocketFixTicks':// no break
        p.default.Damage = ratio * 300.0;
        break;

    case class'#var(prefix)RocketWP':
        p.default.Damage = ratio * 300.0;
        break;

    case class'#var(prefix)HECannister20mm':
        // normally the damage should be * 150, but that means a 50% damage rifle could have trouble breaking many doors even with only 3 explosion ticks
        p.default.Damage = ratio * 180.0;
        p = class'HECannisterFixTicks';
        d = p;
    case class'HECannisterFixTicks':// no break
        p.default.Damage = ratio * 180.0;
        break;

    case class'#var(prefix)Shuriken':
    case class'#var(prefix)Fireball':
        p.default.Damage = new_damage;
        break;

    case class'#var(prefix)GasGrenade':
    case class'#var(prefix)TearGas':
    case class'#var(prefix)GreaselSpit':
    case class'#var(prefix)RocketRobot':
    case class'#var(prefix)LAM':
    case class'#var(prefix)RocketLAW':
    case class'#var(prefix)NanoVirusGrenade':
    case class'#var(prefix)EMPGrenade':
    case class'#var(prefix)GraySpit':
    case class'#var(prefix)RocketMini':
        //TODO: ignore these for now
        break;

    default:
        warning("RandoWeapon("$w$") didn't set damage for projectile "$p$", w.default.HitDamage: "$w.default.HitDamage$", new w.HitDamage: "$w.HitDamage$", p.default.Damage: "$p.default.Damage);
        break;
    }
}

simulated function RemoveRandomWeapon(#var(PlayerPawn) p)
{
    local Inventory i;
    local Weapon weaps[64];
    local int numWeaps, slot;

    for( i = p.Inventory; i != None; i = i.Inventory ) {
        if( Weapon(i) == None ) continue;
        weaps[numWeaps++] = Weapon(i);
    }

    // don't take the player's only weapon
    if( numWeaps <= 1 ) return;

    SetSeed( "RemoveRandomWeapon " $ numWeaps );

    slot = rng(numWeaps);
    info("RemoveRandomWeapon("$p$") Removing weapon "$weaps[slot]$", numWeaps was "$numWeaps);
    p.DeleteInventory(weaps[slot]);
    weaps[slot].Destroy();
}
