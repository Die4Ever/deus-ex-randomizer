class BalanceSpyDrone injects SpyDrone;

state Exploding
{
    function DamageRing()
    {
        local float origDamage;
        origDamage = Damage;

        Damage = origDamage * 0.15;
        DamageType='exploded';
        Super.DamageRing();

        Damage = origDamage * 0.5;
        DamageType='EMP';
        Super.DamageRing();
    }
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name damageType)
{
    Super.TakeDamage(Damage, instigatedBy, HitLocation, Momentum, damageType);

    //Decrease the despawn time of the drone so that it is gone by the time you can reactivate the aug
    //(Since we reduced that timer as well).
    //This fixes an issue where reactivating the aug before the old drone has despawn gives you the camera
    //from the old drone instead, while controlling the new one.
    if (LifeSpan==10.0 && class'AugDrone'.Default.reconstructTime < 10.0){
        LifeSpan=class'AugDrone'.Default.reconstructTime-0.1;
    }
}
