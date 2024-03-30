class WeaponRubberBaton extends #var(prefix)WeaponBaton;

simulated function float GetWeaponSkill()
{
    return 0;
}

defaultproperties
{
    HitDamage=1
    FireSound=Sound'DeusExSounds.Weapons.BatonFire'
    Misc1Sound=Sound'DeusExSounds.Weapons.BatonHitFlesh'
    Misc2Sound=Sound'DeusExSounds.Weapons.BatonHitHard'
    Misc3Sound=Sound'DeusExSounds.Weapons.BatonHitSoft'
    ItemName="Rubber Baton"
    Description="A rubber baton, could be used to break glass windows or wooden crates."
    beltDescription="RUBBER"
}
