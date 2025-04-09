class StealthPistolBalance injects WeaponStealthPistol;

function UpdateBalance()
{
    if(class'MenuChoice_BalanceItems'.static.IsEnabled()) {
        HitDamage = 9;
        BaseAccuracy = 0.6;
        maxRange=1920;
        AccurateRange=960;
    } else {
        HitDamage = 8;
        BaseAccuracy = 0.8;
        maxRange=4800;
        AccurateRange=2400;
    }
    default.HitDamage = HitDamage;
    default.BaseAccuracy = BaseAccuracy;
    default.maxRange=maxRange;
    default.AccurateRange=AccurateRange;
}

// slightly higher damage, lower range, better accuracy
defaultproperties
{
    HitDamage=9
    maxRange=1920
    AccurateRange=960
    BaseAccuracy=0.6
}
