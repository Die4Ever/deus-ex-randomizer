//=============================================================================
// MenuChoice_RandomMusic
//=============================================================================

class MenuChoice_ThrowMelee extends DXRMenuUIChoiceBool;

defaultproperties
{
    enabled=True
    defaultvalue=True
    HelpText="How to handle melee weapons when enemies die."
    actionText="Melee Weapons"
    enumText(0)="Don't Throw"
    enumText(1)="Throw"
}
