//=============================================================================
// WeaponRobotPistol.
//
// Uses our balanced pistol stats
//=============================================================================
class WeaponRobotPistol extends WeaponNPCRanged;

defaultproperties
{
     ShotTime=0.600000
     reloadTime=1.000000
     HitDamage=12
     BaseAccuracy=0.600000
     bHasMuzzleFlash=True
     AmmoName=Class'DeusEx.Ammo10mm'
     PickupAmmoCount=50
     bInstantHit=True
     FireSound=Sound'DeusExSounds.Weapons.PistolFire'
     CockingSound=Sound'DeusExSounds.Weapons.PistolReload'
     SelectSound=Sound'DeusExSounds.Weapons.PistolSelect'
     ItemName="Robot Pistol"
}
