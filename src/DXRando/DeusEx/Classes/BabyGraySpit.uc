//=============================================================================
// BabyGraySpit.
//=============================================================================
class BabyGraySpit extends GraySpit;

simulated function Tick(float deltaTime)
{
	time += deltaTime;

	// scale it up as it flies (Half the size of regular gray spit)
	DrawScale = FClamp((time+0.5), 0.5, 3.0);
}

defaultproperties
{
     AccurateRange=200
     maxRange=300
     Damage=5.000000
     MomentumTransfer=100
     DrawScale=0.5
}
