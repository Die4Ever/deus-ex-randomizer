class DXRHKChair injects HKChair;

function BeginPlay()
{
    if(class'MenuChoice_BalanceEtc'.static.IsDisabled()) {
        SetCollisionSize(CollisionRadius, class'HKChairInjBase'.default.CollisionHeight);
        PrePivot = class'HKChairInjBase'.default.PrePivot;
        sitPoint[0] = class'HKChairInjBase'.default.sitPoint[0];
    }
    Super.BeginPlay();
}

defaultproperties
{
    CollisionHeight=16
    PrePivot=(X=0,Y=0,Z=15)
    sitPoint(0)=(X=0.000000,Y=-8.000000,Z=15)
}
