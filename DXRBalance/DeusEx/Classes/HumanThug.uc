class DXRHumanThug injects HumanThug;

function BeginPlay()
{
    if(class'MenuChoice_BalanceEtc'.static.IsEnabled()) {
        BaseAccuracy=0.3;
    } else {
        BaseAccuracy=1.2;
    }
    default.BaseAccuracy=BaseAccuracy;
    Super.BeginPlay();
}

defaultproperties
{
     BaseAccuracy=0.3
}
