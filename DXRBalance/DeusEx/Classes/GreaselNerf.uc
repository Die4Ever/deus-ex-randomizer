class GreaselNerf injects Greasel;

function BeginPlay()
{
    if(class'MenuChoice_BalanceEtc'.static.IsEnabled()) {
        Health=80;
        HealthHead=80;
        HealthTorso=80;
        HealthLegLeft=80;
        HealthLegRight=80;
        HealthArmLeft=80;
        HealthArmRight=80;
        BaseAccuracy=0.2;
    } else {
        Health=100;
        HealthHead=100;
        HealthTorso=100;
        HealthLegLeft=100;
        HealthLegRight=100;
        HealthArmLeft=100;
        HealthArmRight=100;
        BaseAccuracy=0; // omg
    }
    default.Health=Health;
    default.HealthHead=HealthHead;
    default.HealthTorso=HealthTorso;
    default.HealthLegLeft=HealthLegLeft;
    default.HealthLegRight=HealthLegRight;
    default.HealthArmLeft=HealthArmLeft;
    default.HealthArmRight=HealthArmRight;
    default.BaseAccuracy=BaseAccuracy;
    Super.BeginPlay();
}

// nerf Health and BaseAccuracy
defaultproperties
{
    Health=80
    HealthHead=80
    HealthTorso=80
    HealthLegLeft=80
    HealthLegRight=80
    HealthArmLeft=80
    HealthArmRight=80
    BaseAccuracy=0.2
}
