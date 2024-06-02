class MenuChoice_RefuseMelee extends MenuChoice_ItemRefusal;

defaultproperties
{
    enabled=False
    defaultvalue=False
    HelpText="Should melee weapons be dropped when looting a body?"
    actionText="Drop Melee Weapons"
    enumText(0)="Don't Drop"
    enumText(1)="Drop"

    refusedItems(0)=class'WeaponCombatKnife'
    refusedItems(1)=class'WeaponCrowbar'
    refusedItems(2)=class'WeaponSword'
    refusedItems(3)=class'WeaponNanoSword'
    refusedItems(4)=class'WeaponBaton'
}

