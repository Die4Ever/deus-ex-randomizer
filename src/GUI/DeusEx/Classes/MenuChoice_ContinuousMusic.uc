//=============================================================================
// MenuChoice_ContinuousMusic
//=============================================================================

class MenuChoice_ContinuousMusic extends DXRMenuUIChoiceInt;

var int disabled;
var int simple;
var int advanced;

defaultproperties
{
    value=1
    defaultvalue=1
    disabled=0
    simple=-9
    advanced=1
    enumText(0)="Normal Music"
    enumText(1)="Continuous Music"
    HelpText="Continue music through loading screens."
    actionText="Continuous Music"
}
