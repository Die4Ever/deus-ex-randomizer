class BalanceWeaponMJ12Commando injects WeaponMJ12Commando;

function UpdateBalance()
{
    if(class'MenuChoice_BalanceItems'.static.IsEnabled()) {
        HitDamage = 12;
    } else {
        HitDamage = 15;
    }
    default.HitDamage = HitDamage;
}

defaultproperties
{
     HitDamage=12
}
