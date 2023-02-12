class DXRBlackHelicopter injects BlackHelicopter;

singular function SupportActor(Actor standingActor)
{
	// kill whatever lands on the blades
	if (standingActor != None)
		standingActor.TakeDamage(10000, None, standingActor.Location, vect(0,0,0), 'Helicopter'); //Just change the damage type
}

function BeginPlay()
{
    Super.BeginPlay();
    if(CollisionRadius>default.CollisionRadius)
        SetCollisionSize(default.CollisionRadius, CollisionHeight);
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
