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
