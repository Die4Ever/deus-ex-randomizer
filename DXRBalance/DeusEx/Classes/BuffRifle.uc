class BuffRifle injects WeaponAssaultGun;

function BeginPlay()
{
    if(class'MenuChoice_BalanceItems'.static.IsDisabled()) {
        HitDamage = 3;
        maxRange = 9600;
        AccurateRange = 4800;
    } else {
        HitDamage = 4;
        maxRange = 2000;
        AccurateRange = 1000;
    }
    default.HitDamage = HitDamage;
    default.maxRange = maxRange;
    default.AccurateRange = AccurateRange;
    Super.BeginPlay();
}

// way lower range, 4 damage
defaultproperties
{
    HitDamage=4
    maxRange=2000
    AccurateRange=1000
}
