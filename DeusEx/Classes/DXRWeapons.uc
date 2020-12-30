class DXRWeapons extends DXRBase;

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
    local float f;
    //l("RandoWeapon("$w$")");
    dxr.SetSeed( dxr.Crc(dxr.seed $ "RandoWeapon " $ w.class.name ) );

    f = float(w.default.HitDamage) * (rngf()+0.5);
    w.HitDamage = int(f);
    //w.HitDamage = 90001;
    f = w.default.ShotTime * (rngf()+0.5);
    w.ShotTime = f;
    /*f = w.default.ReloadTime * (rngf()+0.5);
    w.ReloadTime = f;
    f = float(w.default.MaxRange) * (rngf()+0.5);
    w.MaxRange = int(f);
    f = float(w.default.AccurateRange) * (rngf()+0.5);
    w.AccurateRange = int(f);
    f = w.default.BaseAccuracy * (rngf()+0.5);
    w.BaseAccuracy = f;*/
}
