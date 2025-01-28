class BuffRifle injects WeaponAssaultGun;

function BeginPlay()
{
    if(class'DXRFlags'.default.bZeroRandoPure) {
        HitDamage = 3;
    } else {
        HitDamage = 4;
    }
    default.HitDamage = HitDamage;
    Super.BeginPlay();
}

defaultproperties
{
    HitDamage=4
}
