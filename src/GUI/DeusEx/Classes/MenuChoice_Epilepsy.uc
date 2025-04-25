class MenuChoice_Epilepsy extends DXRMenuUIChoiceBool;

defaultproperties
{
    enabled=False
    defaultvalue=False
    HelpText="Enable or Disable Epilepsy-Safe mode.  Flickering or strobing lights will be changed to a soft pulse."
    actionText="Flickering Lights"
    enumText(0)="Regular Lighting"
    enumText(1)="Epilepsy-Safe"
}
