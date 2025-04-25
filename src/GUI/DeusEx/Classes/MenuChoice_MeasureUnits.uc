class MenuChoice_MeasureUnits extends DXRMenuUIChoiceInt;

static function bool IsImperial()
{
    return (default.value==0);
}

static function bool IsMetric()
{
    return (default.value==1);
}

defaultproperties
{
    value=0
    defaultvalue=0
    defaultInfoWidth=243
    defaultInfoPosX=203
    HelpText="What units should measurements be displayed in?"
    actionText="Measurement Units"
    enumText(0)="Imperial"
    enumText(1)="Metric"
}
