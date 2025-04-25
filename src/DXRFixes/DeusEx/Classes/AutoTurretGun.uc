class AutoTurretGun injects AutoTurretGun;

auto state Active
{
    function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
    {
        local AutoTurret turret;

        if (DamageType == 'NanoVirus') {
            //Pass the "damage" along to the base.
            //This makes it a bit easier to hit some tucked away turrets
            turret = AutoTurret(Owner);
            turret.HandleScrambler(EventInstigator,Damage);
        }

        Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
    }
}
