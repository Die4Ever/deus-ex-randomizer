class DXRTearGas injects TearGas;

function BeginPlay()
{
    if(class'MenuChoice_BalanceItems'.static.IsEnabled()) {
        Damage = 2;
    } else {
        Damage = 1;
    }
    default.Damage = Damage;
    Super.BeginPlay();
}

defaultproperties
{
    Damage=2// vanilla is 1
}
