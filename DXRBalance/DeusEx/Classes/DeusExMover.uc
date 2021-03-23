class DeusExMover injects DeusExMover;

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
	if (bDestroyed)
		return;

	if ((damageType == 'TearGas') || (damageType == 'PoisonGas') || (damageType == 'HalonGas'))
		return;

	if ((damageType == 'Stunned') || (damageType == 'Radiation'))
		return;

	if ((DamageType == 'EMP') || (DamageType == 'NanoVirus') || (DamageType == 'Shocked'))
		return;

	if (bBreakable)
	{
		// add up the damage
		if (Damage >= minDamageThreshold)
			doorStrength -= Damage * 0.002;
//		else
//			doorStrength -= Damage * 0.001;		// damage below the threshold does 1/10th the damage

		doorStrength = FClamp(doorStrength, 0.0, 1.0);
		if (doorStrength ~= 0.0)
			BlowItUp(instigatedBy);
	}
}
