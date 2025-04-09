class MenuChoice_DecoPickupBehaviour extends DXRMenuUIChoiceBool;

defaultproperties
{
    enabled=False
    defaultvalue=False
    HelpText="Select how you want the game to behave when you try to pick up an object while holding something in your hands.  By default, you must manually put away the item yourself."
    actionText="Pick Up While Hands Full"
    enumText(0)="Do Nothing"
    enumText(1)="Auto Empty Hands"
}
