class MenuChoice_SaveDuringInfolinks extends DXRMenuUIChoiceInt;

static function bool IsEnabled(DXRFlags f)
{
    return (default.value==2) || (default.value==1 && !f.IsReducedRando());
}

defaultproperties
{
    value=1
    defaultvalue=1
    defaultInfoWidth=243
    defaultInfoPosX=203
    HelpText="Saving during Infolinks can cause dialog to be missed, not recommended for first playthroughs."
    actionText="Saving During Infolinks"
    enumText(0)="Can't save during Infolinks"
    enumText(1)="According to Game Mode"
    enumText(2)="Saving skips infolinks"
}
