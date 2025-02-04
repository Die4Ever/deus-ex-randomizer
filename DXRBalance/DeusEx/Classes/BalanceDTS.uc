class BalanceDTS injects WeaponNanoSword;

function BeginPlay()
{
    if(class'MenuChoice_BalanceItems'.static.IsEnabled()) {
        HitDamage = 24;
        AreaOfEffect = AOE_Point;
    } else {
        HitDamage = 20;
        AreaOfEffect = AOE_Cone;
    }
    default.HitDamage = HitDamage;
    default.AreaOfEffect = AreaOfEffect;
    Super.BeginPlay();
}

// original HitDamage was 20, AOE_Cone causes it to be treated as a shotgun with 3 (or 5?) projectiles multiplying the damage, see DeusExWeapon and search for AOE_Cone
// interesting side effect of increasing HitDamage from 20 to 24 is that the door strength threshold is measured per hit, so now this can break more doors than it could before, with the combat strength aug it should be able to break even more than the sniper rifle can
defaultproperties
{
    HitDamage=24
    AreaOfEffect=AOE_Point
}
