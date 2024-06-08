class DXRAttackHelicopter injects AttackHelicopter;

singular function SupportActor(Actor standingActor)
{
    local Vector momentum;
    // kill whatever lands on the blades
    if (standingActor != None) {
        momentum = Normal(standingActor.Location - Location) * 100.0;
        momentum.Z = 0;
        standingActor.TakeDamage(10000, None, standingActor.Location, momentum, 'Helicopter'); //Just change the damage type
    }
}

/////////////////////////////////////////////////////////////
///////////////States copied from base class/////////////////
//////Including these allows old save games to load//////////
/////////////////////////////////////////////////////////////


auto state Flying
{
	function BeginState()
	{
		Super.BeginState();
		LoopAnim('Fly');
	}
}

defaultproperties
{
    CollisionRadius=360
}
