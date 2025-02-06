class DXRWeaponRifle injects WeaponRifle;

function UpdateBalance()
{
    if(class'MenuChoice_BalanceItems'.static.IsEnabled()) {
        ShotTime = 1;
        ReloadCount = 1;
        ReloadTime = 1;
        bCanHaveModReloadCount = false;
    } else {
        ShotTime = 1.5;
        ReloadCount = 6;
        ReloadTime = 1;
        bCanHaveModReloadCount = true;
    }
    default.ShotTime = ShotTime;
    default.ReloadCount = ReloadCount;
    default.ReloadTime = ReloadTime;
    default.bCanHaveModReloadCount = bCanHaveModReloadCount;
}

// vanilla is shottime=1.5, reloadcount=6, reloadtime=1 (inherited from DeusExWeapon), bCanHaveModReloadCount=True
defaultproperties
{
    ShotTime=1
    bHasMuzzleFlash=True
    ReloadCount=1
    ReloadTime=1
    bCanHaveModReloadCount=False
}
