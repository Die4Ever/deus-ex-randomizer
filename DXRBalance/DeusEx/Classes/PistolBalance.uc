class PistolBalance injects WeaponPistol;

function BeginPlay()
{
    if(class'DXRFlags'.default.bZeroRandoPure) {
        HitDamage = 14;
        BaseAccuracy = 0.7;
    } else {
        HitDamage = 12;
        BaseAccuracy = 0.6;
    }
    default.HitDamage = HitDamage;
    default.BaseAccuracy = BaseAccuracy;
    Super.BeginPlay();
}

// lower damage and range, better accuracy
defaultproperties
{
    HitDamage=12
    maxRange=2000
    AccurateRange=1000
    BaseAccuracy=0.6
}
