class BalanceDTS injects WeaponNanoSword;
// original HitDamage was 20, AOE_Cone causes it to be treated as a shotgun with 3 (or 5?) projectiles multiplying the damage, see DeusExWeapon and search for AOE_Cone
// interesting side effect of increasing HitDamage from 20 to 24 is that the door strength threshold is measured per hit, so now this can break more doors than it could before, with the combat strength aug it should be able to break even more than the sniper rifle can
simulated function PreBeginPlay()
{
    HitDamage=default.HitDamage;
    AreaOfEffect=default.AreaOfEffect;
	Super.PreBeginPlay();
}

defaultproperties
{
    HitDamage=24
    AreaOfEffect=AOE_Point
}
