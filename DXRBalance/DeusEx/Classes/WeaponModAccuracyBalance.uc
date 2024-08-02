class DXRWeaponModAccuracyBalance injects WeaponModAccuracy;

simulated function bool CanUpgradeWeapon(DeusExWeapon weapon)
{
    if (weapon == None) return false;
    return (weapon.bCanHaveModBaseAccuracy && weapon.ModBaseAccuracy <= 0.5);
}

defaultproperties
{
    WeaponModifier=0.15
}
