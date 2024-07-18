class WeaponModRangeBuffs injects WeaponModRange;

function ApplyMod(DeusExWeapon weapon)
{
    if (weapon != None)
    {
        weapon.AccurateRange    += (weapon.Default.AccurateRange * WeaponModifier);
        weapon.maxRange         += (weapon.Default.maxRange * WeaponModifier);
        weapon.ModAccurateRange += WeaponModifier;
    }
}

simulated function bool CanUpgradeWeapon(DeusExWeapon weapon)
{
    if (weapon != None)
        return (weapon.bCanHaveModAccurateRange && weapon.ModAccurateRange < 1.5);
    else
        return False;
}

defaultproperties
{
    WeaponModifier=0.25
}
