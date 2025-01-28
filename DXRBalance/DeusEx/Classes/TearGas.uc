class DXRTearGas injects TearGas;

function BeginPlay()
{
    if(class'MenuChoice_BalanceItems'.static.IsDisabled()) {
        Damage = 1;
    } else {
        Damage = 2;
    }
    default.Damage = Damage;
    Super.BeginPlay();
}

defaultproperties
{
    Damage=2// vanilla is 1
}
