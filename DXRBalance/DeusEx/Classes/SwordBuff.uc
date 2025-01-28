class SwordBuff injects WeaponSword;

function BeginPlay()
{
    if(class'DXRFlags'.default.bZeroRandoPure) {
        HitDamage = 10;
        anim_speed = 1;
    } else {
        HitDamage = 12;
        anim_speed = 1.1;
    }
    default.HitDamage = HitDamage;
    default.anim_speed = anim_speed;
    Super.BeginPlay();
}

// vanilla is 64 range, 10 damage
defaultproperties
{
    maxRange=96
    AccurateRange=96
    HitDamage=12
    anim_speed=1.1
}
