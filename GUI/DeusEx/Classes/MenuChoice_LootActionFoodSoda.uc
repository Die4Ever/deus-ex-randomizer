class MenuChoice_LootActionFoodSoda extends MenuChoice_LootAction;
#compileif injections

defaultproperties
{
    HelpText="Should food and soda be included in the list of Junk items that get dropped when looting a body, or get consumed automatically?"
    actionText="Food and Soda"

    itemClasses(0)=class'SoyFood'
    itemClasses(1)=class'Candybar'
    itemClasses(2)=class'Sodacan'
    enumText(2)="Consume"
}
