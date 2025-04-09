class PistolBalance injects WeaponPistol;

function UpdateBalance()
{
    if(class'MenuChoice_BalanceItems'.static.IsEnabled()) {
        HitDamage = 12;
        BaseAccuracy = 0.6;
        maxRange=1920;
        AccurateRange=960;
    } else {
        HitDamage = 14;
        BaseAccuracy = 0.7;
        maxRange=4800;
        AccurateRange=2400;
    }
    default.HitDamage = HitDamage;
    default.BaseAccuracy = BaseAccuracy;
    default.maxRange=maxRange;
    default.AccurateRange=AccurateRange;
}

// lower damage and range, better accuracy
defaultproperties
{
    HitDamage=12
    maxRange=1920
    AccurateRange=960
    BaseAccuracy=0.6
}
