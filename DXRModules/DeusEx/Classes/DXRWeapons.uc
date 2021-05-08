class DXRWeapons extends DXRBase;

var config float min_weapon_dmg;
var config float max_weapon_dmg;
var config float min_weapon_shottime;
var config float max_weapon_shottime;

var DXRLoadouts loadouts;

replication
{
    reliable if( Role == ROLE_Authority )
        min_weapon_dmg, max_weapon_dmg, min_weapon_shottime, max_weapon_shottime;
}

function CheckConfig()
{
    if( config_version < class'DXRFlags'.static.VersionToInt(1,4,8) ) {
        min_weapon_dmg = 0.5;
        max_weapon_dmg = 1.5;
        min_weapon_shottime = 0.5;
        max_weapon_shottime = 1.5;
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

simulated function PlayerAnyEntry(#var PlayerPawn  p)
{
    Super.PlayerAnyEntry(p);
    AnyEntry();
}

simulated function RandoWeapon(DeusExWeapon w)
{
    local int oldseed;
    if( dxr == None ) return;
    oldseed = dxr.SetSeed( dxr.Crc(dxr.seed $ "RandoWeapon " $ w.class.name ) );

    if( loadouts != None ) loadouts.AdjustWeapon(w);

    w.HitDamage = rngrange(float(w.default.HitDamage), min_weapon_dmg, max_weapon_dmg);
    if( #var prefix WeaponHideAGun(w) == None && w.ProjectileClass != None ) {
        //don't do this for the PS20/PS40 because it shares the PlasmaBolt projectile with the PlasmaRifle in a really dumb way, the PS40 code handles this itself
        //I might move this logic into an injector into DeusExProjectile, maybe in BeginPlay it could check its owner and copy the HitDamage from there?
        switch(w.ProjectileClass) {
            case class'#var prefix Dart':
                w.ProjectileClass.default.Damage = 0.6 * float(w.HitDamage);
                break;
            
            case class'#var prefix DartFlare':
            case class'#var prefix DartPoison':
                w.ProjectileClass.default.Damage = 0.2 * float(w.HitDamage);
                break;
            
            case class'#var prefix PlasmaBolt':
                w.ProjectileClass.default.Damage = 1.15 * float(w.HitDamage);
                break;

            case class'#var prefix Fireball':
                w.ProjectileClass.default.Damage = float(w.HitDamage);
                break;
            
            case class'#var prefix Rocket':
                w.ProjectileClass.default.Damage = float(w.HitDamage);
                break;

            case class'#var prefix Shuriken':
                w.ProjectileClass.default.Damage = float(w.HitDamage);
                break;

            case class'#var prefix GasGrenade':
            case class'#var prefix TearGas':
            case class'#var prefix GreaselSpit':
            case class'#var prefix RocketRobot':
            case class'#var prefix LAM':
            case class'#var prefix RocketLAW':
            case class'#var prefix NanoVirusGrenade':
            case class'#var prefix EMPGrenade':
            case class'#var prefix GraySpit':
            case class'#var prefix RocketMini':
                //ignore these for now
                break;
            
            default:
                warning("RandoWeapon("$w$") didn't set damage for projectile "$w.ProjectileClass$", w.default.HitDamage: "$w.default.HitDamage$", new w.HitDamage: "$w.HitDamage$", w.ProjectileClass.default.Damage: "$w.ProjectileClass.default.Damage);
                break;
        }
    }
    w.ShotTime = rngrange(w.default.ShotTime, min_weapon_shottime, max_weapon_shottime);
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

simulated function RemoveRandomWeapon(#var PlayerPawn  p)
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

    slot = rng(numWeaps);
    info("RemoveRandomWeapon("$p$") Removing weapon "$weaps[slot]$", numWeaps was "$numWeaps);
    p.DeleteInventory(weaps[slot]);
    weaps[slot].Destroy();
}
