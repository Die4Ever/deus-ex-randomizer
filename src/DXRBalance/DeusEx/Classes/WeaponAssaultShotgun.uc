class DXRWeaponAssaultShotgun injects WeaponAssaultShotgun;

function UpdateBalance()
{
    if(class'MenuChoice_BalanceItems'.static.IsEnabled()) {
        HitDamage = 5;
        BaseAccuracy = 0.65;
        AccurateRange = 800;
        maxRange = 1200;
        AIMaxRange = 448;
    } else {
        HitDamage = 4;
        BaseAccuracy = 0.8;
        AccurateRange = 1200;
        maxRange = 2400;
        AIMaxRange = 800;
    }
    default.HitDamage = HitDamage;
    default.BaseAccuracy = BaseAccuracy;
    default.AccurateRange = AccurateRange;
    default.maxRange = maxRange;
    default.AIMaxRange = AIMaxRange;
}

// vanilla is 4 damage, 0.8 accuracy, 1200 AccurateRange, 2400 maxRange
defaultproperties
{
    HitDamage=5
    BaseAccuracy=0.65
    maxRange=1200
    AccurateRange=800
    MinSpreadAcc=0.2
    AIMaxRange=448
    AfterShotTime=-0.3327315
}
