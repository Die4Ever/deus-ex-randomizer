class WeaponFlashGrenade extends WeaponGasGrenade;
// or should it extend a different type of grenade for cosmetics? emp? it's a bit buggy if you use your last flash grenade when you also have gas grenades?

defaultproperties
{
    AmmoName=Class'DeusEx.AmmoFlashGrenade'
    ProjectileClass=Class'DeusEx.FlashGrenade'
    ItemName="Flashbang Grenade"
    Description="Flashbang grenade."
    beltDescription="FLASH GREN"
}
