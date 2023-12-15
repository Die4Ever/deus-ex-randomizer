class DXRFireballShrinking extends Fireball;

simulated function Tick(float deltaTime)
{
	local float value;
	local float sizeMult;

	// don't Super.Tick() becuase we don't want gravity to affect the stream
    // Super(DeusExProjectile).Tick(deltaTime);
	time += deltaTime;

	value = 1.0+time;
	if (MinDrawScale > 0)
		sizeMult = MaxDrawScale/MinDrawScale;
	else
		sizeMult = 1;

	DrawScale = (sizeMult/(value*value) + (sizeMult+1))*MinDrawScale;
	ScaleGlow = Default.ScaleGlow/(value*value*value);
}
