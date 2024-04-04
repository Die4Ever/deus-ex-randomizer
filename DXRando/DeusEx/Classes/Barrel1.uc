class DXRBarrel1 injects #var(prefix)Barrel1;

var travel ESkinColor _SkinColor;

function BeginPlay()
{
    bExplosive=Default.bExplosive;
    explosionDamage=Default.explosionDamage;
    explosionRadius=Default.explosionRadius;
    Super.BeginPlay();
    bInvincible = false;
    _SkinColor = SkinColor;
}

event TravelPostAccept()
{
    Super.TravelPostAccept();
    SkinColor = _SkinColor;
    BeginPlay();
}

function Trigger(Actor Other, Pawn Instigator)
{
    TakeDamage(50,Instigator,Location,vect(0,0,0),'shot'); //Destroy the barrel if it is triggered
}

auto state Active
{
    function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
    {
        //Don't get zapped by electricity
        //Prevents the big smoke cloud in airfield that lags everything
        if (damageType=='Shocked'){
            return;
        }

        Super.TakeDamage(Damage,instigatedBy,hitLocation,momentum,damageType);
    }
}
