class DXRHumanCivilian injects HumanCivilian;

function BeginPlay()
{
    if(class'MenuChoice_BalanceEtc'.static.IsEnabled()) {
        BaseAccuracy=0.5;
    } else {
        BaseAccuracy=1.2;
    }
    default.BaseAccuracy=BaseAccuracy;
    Super.BeginPlay();
}

defaultproperties
{
    BaseAccuracy=0.5
}
