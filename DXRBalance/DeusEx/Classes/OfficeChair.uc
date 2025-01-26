class DXROfficeChair injects OfficeChair;

function BeginPlay()
{
    if(class'DXRFlags'.default.bZeroRandoPure) {
        SetCollisionSize(CollisionRadius, class'OfficeChairInjBase'.default.CollisionHeight);
        PrePivot = class'OfficeChairInjBase'.default.PrePivot;
        sitPoint[0] = class'OfficeChairInjBase'.default.sitPoint[0];
    }
    Super.BeginPlay();
}

defaultproperties
{
    CollisionHeight=15.549999
    PrePivot=(X=0,Y=0,Z=9)
    sitPoint(0)=(X=0.000000,Y=-4.000000,Z=9)
}
