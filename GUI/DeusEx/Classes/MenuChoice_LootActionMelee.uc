class MenuChoice_LootActionMelee extends MenuChoice_LootAction;
#compileif injections

defaultproperties
{
    HelpText="Should melee weapons be included in the list of Junk items that get dropped when looting a body?"
    actionText="Melee Weapons"

    itemClasses(0)=class'WeaponCombatKnife'
    itemClasses(1)=class'WeaponCrowbar'
    itemClasses(2)=class'WeaponSword'
    itemClasses(3)=class'WeaponNanoSword'
    itemClasses(4)=class'WeaponBaton'
}
