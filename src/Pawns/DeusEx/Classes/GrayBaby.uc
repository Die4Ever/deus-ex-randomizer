//=============================================================================
// GrayBaby.
//=============================================================================
class GrayBaby extends #var(prefix)Gray;

defaultproperties
{
     MinHealth=3.000000
     CarcassType=Class'DeusEx.GrayBabyCarcass'
     WalkingSpeed=0.185000
     bShowPain=True
     walkAnimMult=2.500000
     runAnimMult=2.500000
     GroundSpeed=450.000000
     WaterSpeed=80.000000
     Health=15
     DrawScale=0.600000
     CollisionRadius=17.124
     CollisionHeight=21.6
     Mass=60.000000
     Buoyancy=50.000000
     BindName="GrayBaby"
     FamiliarName="Baby Gray"
     UnfamiliarName="Baby Gray"
     DamageRadius=128.000000
     DamageAmount=5.000000
     InitialInventory(0)=(Inventory=Class'WeaponBabyGraySwipe')
     InitialInventory(1)=(Inventory=Class'DeusEx.WeaponGraySpit')
     InitialInventory(2)=(Inventory=Class'DeusEx.AmmoGraySpit',Count=9999)
}
