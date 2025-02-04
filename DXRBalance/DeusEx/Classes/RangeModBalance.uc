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

function BeginPlay()
{
    if(class'MenuChoice_BalanceItems'.static.IsEnabled()) {
        WeaponModifier = 0.25;
    } else {
        WeaponModifier = 0.1;
    }
    default.WeaponModifier = WeaponModifier;
    Super.BeginPlay();
}

defaultproperties
{
    WeaponModifier=0.25
}
