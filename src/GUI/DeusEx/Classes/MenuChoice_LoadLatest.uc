class MenuChoice_LoadLatest extends DXRMenuUIChoiceBool;

defaultproperties
{
    enabled=True
    defaultvalue=True
    defaultInfoWidth=243
    defaultInfoPosX=203
    HelpText="Quick Load button will load the most recent save, even if it isn't the quicksave."
    actionText="Quick Load"
    enumText(0)="Only load Quick Save"
    enumText(1)="Load latest save"
}
