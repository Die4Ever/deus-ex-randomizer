class GreaselNerf injects Greasel;

function BeginPlay()
{
    if(class'MenuChoice_BalanceEtc'.static.IsEnabled()) {
        Health=80;
        BaseAccuracy=0.2;
    } else {
        Health=100;
        BaseAccuracy=0; // omg
    }
    default.Health=Health;
    default.BaseAccuracy=BaseAccuracy;
    Super.BeginPlay();
}

// nerf Health and BaseAccuracy
defaultproperties
{
    Health=80
    BaseAccuracy=0.2
}
