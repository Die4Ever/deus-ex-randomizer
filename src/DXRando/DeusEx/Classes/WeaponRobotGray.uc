//=============================================================================
// WeaponRobotGray.
//=============================================================================
class WeaponRobotGray extends WeaponNPCRanged;

// fire weapons out of alternating sides
function Fire(float Value)
{
	PlayerViewOffset.Y = -PlayerViewOffset.Y;
	Super.Fire(Value);
}

defaultproperties
{
     HitDamage=8
     maxRange=1500
     AccurateRange=750
     AreaOfEffect=AOE_Cone
     AmmoName=Class'DeusEx.AmmoGraySpit'
     PickupAmmoCount=50
     ProjectileClass=Class'RobotGraySpit'
     PlayerViewOffset=(Y=-24.000000,Z=-12.000000)
     ItemName="Radiation Weapon"
}
