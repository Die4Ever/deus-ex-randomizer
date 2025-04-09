//=============================================================================
// MenuChoice_ThrowMelee
//=============================================================================

class MenuChoice_ThrowMelee extends DXRMenuUIChoiceBool;

defaultproperties
{
    enabled=False
    defaultvalue=False
    HelpText="How to handle melee weapons when enemies die."
    actionText="Melee Weapons"
    enumText(0)="Don't Throw"
    enumText(1)="Throw"
}
