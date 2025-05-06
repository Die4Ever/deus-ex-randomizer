class DXRWHChairDining injects #var(prefix)WHChairDining;

function BeginPlay()
{
    if(class'MenuChoice_BalanceEtc'.static.IsDisabled()) {
        SetCollisionSize(CollisionRadius, class'WHChairDiningInjBase'.default.CollisionHeight);
        PrePivot = class'WHChairDiningInjBase'.default.PrePivot;
        sitPoint[0] = class'WHChairDiningInjBase'.default.sitPoint[0];
    }
    Super.BeginPlay();
}

defaultproperties
{
    CollisionHeight=18
    PrePivot=(X=0,Y=0,Z=16)
    sitPoint(0)=(X=0.000000,Y=-6.000000,Z=10.500000)
}
