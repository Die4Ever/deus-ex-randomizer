class DXRChair1 injects Chair1;

function BeginPlay()
{
    if(class'DXRFlags'.default.bZeroRandoPure) {
        SetCollisionSize(CollisionRadius, class'Chair1InjBase'.default.CollisionHeight);
        PrePivot = class'Chair1InjBase'.default.PrePivot;
        sitPoint[0] = class'Chair1InjBase'.default.sitPoint[0];
    }
    Super.BeginPlay();
}

defaultproperties
{
    CollisionHeight=16
    PrePivot=(X=0,Y=0,Z=14)
    sitPoint(0)=(X=0.000000,Y=-6.000000,Z=10.500000)
}
