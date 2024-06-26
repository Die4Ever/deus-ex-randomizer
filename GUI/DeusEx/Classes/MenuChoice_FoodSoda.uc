class MenuChoice_FoodSoda extends MenuChoice_ItemRefusal;
#compileif injections

defaultproperties
{
    HelpText="Should food and soda be included in the list of Junk items that get dropped when looting a body, or consumed automatically?"
    actionText="Food and Soda"

    refusedItems(0)=class'SoyFood'
    refusedItems(1)=class'Candybar'
    refusedItems(2)=class'Sodacan'
    enumText(2)="Consume"
}
