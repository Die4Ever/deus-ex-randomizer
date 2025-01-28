class StealthPistolBalance injects WeaponStealthPistol;

function BeginPlay()
{
    if(class'MenuChoice_BalanceItems'.static.IsDisabled()) {
        HitDamage = 8;
        BaseAccuracy = 0.8;
    } else {
        HitDamage = 9;
        BaseAccuracy = 0.6;
    }
    default.HitDamage = HitDamage;
    default.BaseAccuracy = BaseAccuracy;
    Super.BeginPlay();
}

// slightly higher damage, lower range, better accuracy
defaultproperties
{
    HitDamage=9
    maxRange=2000
    AccurateRange=1000
    BaseAccuracy=0.6
}
