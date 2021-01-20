class DXRWeapons extends DXRBase;

var config float min_weapon_dmg;
var config float max_weapon_dmg;
var config float min_weapon_shottime;
var config float max_weapon_shottime;

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

function AnyEntry()
{
    local DeusExWeapon w;
    Super.AnyEntry();

    foreach AllActors(class'DeusExWeapon', w) {
        RandoWeapon(w);
    }
}

function RandoWeapon(DeusExWeapon w)
{
    local int oldseed;
    oldseed = dxr.SetSeed( dxr.Crc(dxr.seed $ "RandoWeapon " $ w.class.name ) );

    w.HitDamage = rngrange(float(w.default.HitDamage), min_weapon_dmg, max_weapon_dmg);
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
