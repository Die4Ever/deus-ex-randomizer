class DynamicBlockAll extends BlockAll;

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
    local int i, num;

    switch(DamageType) {
    case 'Shot':
    case 'AutoShot':
    case 'Sabot':
    case 'Exploded':
        num = Clamp(Damage/5, 1, 4);
        for(i=0; i<num; i++) {
            spawn(class'Rockchip',,,HitLocation);
        }
        break;
    };
}

defaultproperties
{
    bStatic=False
}
