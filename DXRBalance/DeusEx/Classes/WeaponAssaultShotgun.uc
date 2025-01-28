class DXRWeaponAssaultShotgun injects WeaponAssaultShotgun;

function BeginPlay()
{
    if(class'DXRFlags'.default.bZeroRandoPure) {
        HitDamage = 4;
        BaseAccuracy = 0.8;
        AccurateRange = 1200;
        maxRange = 2400;
        AIMaxRange = 800;
    } else {
        HitDamage = 5;
        BaseAccuracy = 0.65;
        AccurateRange = 800;
        maxRange = 1200;
        AIMaxRange = 450;
    }
    default.HitDamage = HitDamage;
    default.BaseAccuracy = BaseAccuracy;
    default.AccurateRange = AccurateRange;
    default.maxRange = maxRange;
    default.AIMaxRange = AIMaxRange;
    Super.BeginPlay();
}

// vanilla is 4 damage, 0.8 accuracy, 1200 AccurateRange, 2400 maxRange
defaultproperties
{
    HitDamage=5
    BaseAccuracy=0.65
    maxRange=1200
    AccurateRange=800
    MinSpreadAcc=0.2
    AIMaxRange=450
}
