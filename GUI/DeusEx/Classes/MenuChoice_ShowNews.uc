//=============================================================================
// MenuChoice_ShowNews
//=============================================================================

class MenuChoice_ShowNews extends DXRMenuUIChoiceBool;

defaultproperties
{
    enabled=True
    defaultInfoWidth=243
    defaultInfoPosX=203
    HelpText="Show or hide the news on the main menu. Reopen the main menu to take effect."
    actionText="News on the main menu"
    enumText(0)="News Hidden"
    enumText(1)="News Shown"
}
