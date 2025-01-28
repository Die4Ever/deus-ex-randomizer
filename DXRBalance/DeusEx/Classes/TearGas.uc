class DXRTearGas injects TearGas;

function BeginPlay()
{
    if(class'DXRFlags'.default.bZeroRandoPure) {
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
