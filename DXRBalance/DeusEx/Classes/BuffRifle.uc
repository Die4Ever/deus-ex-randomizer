class BuffRifle injects WeaponAssaultGun;

function UpdateBalance()
{
    if(class'MenuChoice_BalanceItems'.static.IsEnabled()) {
        HitDamage = 4;
        maxRange = 2000;
        AccurateRange = 1000;
    } else {
        HitDamage = 3;
        maxRange = 9600;
        AccurateRange = 4800;
    }
    default.HitDamage = HitDamage;
    default.maxRange = maxRange;
    default.AccurateRange = AccurateRange;
}

// way lower range, 4 damage
defaultproperties
{
    HitDamage=4
    maxRange=2000
    AccurateRange=1000
}
