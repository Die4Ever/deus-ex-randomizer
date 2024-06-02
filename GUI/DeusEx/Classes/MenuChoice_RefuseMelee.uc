class MenuChoice_RefuseMelee extends MenuChoice_ItemRefusal;

defaultproperties
{
    enabled=False
    defaultvalue=False
    HelpText="When starting a new game, should melee weapons be added to the list of Junk items that get dropped when looting a corpse?"
    actionText="Melee Weapons"
    enumText(0)="Not Junk"
    enumText(1)="Junk"

    refusedItems(0)=class'WeaponCombatKnife'
    refusedItems(1)=class'WeaponCrowbar'
    refusedItems(2)=class'WeaponSword'
    refusedItems(3)=class'WeaponNanoSword'
    refusedItems(4)=class'WeaponBaton'
}
