class DXRWeaponSawedOffShotgun injects WeaponSawedOffShotgun;

function BeginPlay()
{
    if(class'MenuChoice_BalanceItems'.static.IsDisabled()) {
        HitDamage = 5;
        BaseAccuracy = 0.6;
        AccurateRange = 1200;
        maxRange = 2400;
        AIMaxRange = 800;
    } else {
        HitDamage = 6;
        BaseAccuracy = 0.7;
        AccurateRange = 700;
        maxRange = 1000;
        AIMaxRange = 450;
    }
    default.HitDamage = HitDamage;
    default.BaseAccuracy = BaseAccuracy;
    default.AccurateRange = AccurateRange;
    default.maxRange = maxRange;
    default.AIMaxRange = AIMaxRange;
    Super.BeginPlay();
}

// vanilla is 5 damage, 0.6 accuracy, 1200 AccurateRange, 2400 maxRange
defaultproperties
{
    HitDamage=6
    BaseAccuracy=0.7
    maxRange=1000
    AccurateRange=700
    MinSpreadAcc=0.25
    AIMaxRange=450
}
