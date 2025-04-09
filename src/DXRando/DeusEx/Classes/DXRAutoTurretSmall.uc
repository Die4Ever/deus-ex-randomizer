class DXRAutoTurretSmall injects #var(prefix)AutoTurretSmall;

function Fire()
{
    //Small turrets fire at half the rate of full-sized turrets, so animate the barrel at half rate too
    if (!gun.IsAnimating()){
        gun.LoopAnim('Fire',0.5);
    }

    Super.Fire();
}

defaultproperties
{
     fireRate=0.500000
}
