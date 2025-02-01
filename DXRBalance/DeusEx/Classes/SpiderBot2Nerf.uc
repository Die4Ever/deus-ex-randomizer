class SpiderBot2Nerf injects SpiderBot2;

function BeginPlay()
{
    if(class'MenuChoice_BalanceEtc'.static.IsEnabled()) {
        Health=70;
        GroundSpeed=280;
    } else {
        Health=80;
        GroundSpeed=300;
    }
    default.Health=Health;
    default.GroundSpeed=GroundSpeed;
    Super.BeginPlay();
}

// nerf Health and GroundSpeed
defaultproperties
{
    Health=70
    GroundSpeed=280.000000
}
