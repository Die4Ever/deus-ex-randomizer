class SwordBuff injects WeaponSword;

function UpdateBalance()
{
    if(class'MenuChoice_BalanceItems'.static.IsEnabled()) {
        HitDamage = 12;
        anim_speed = 1.1;
    } else {
        HitDamage = 10;
        anim_speed = 1;
    }
    default.HitDamage = HitDamage;
    default.anim_speed = anim_speed;
}

// vanilla is 64 range, 10 damage, 64 range (I honestly consider this to be a bug)
defaultproperties
{
    maxRange=96
    AccurateRange=96
    HitDamage=12
    anim_speed=1.1
}
