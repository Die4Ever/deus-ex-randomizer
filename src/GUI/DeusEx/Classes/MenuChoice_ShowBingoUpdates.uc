class MenuChoice_ShowBingoUpdates extends DXRMenuUIChoiceInt;

static function bool MessagesEnabled(DXRFlags f)
{
    if(f.IsHordeMode()) return false;
    return (default.value==2) ||
           (default.value==3) ||
           (default.value==1 && !f.IsReducedRando() && !f.IsSpeedrunMode()) ||
           (default.value==1 && f.settings.bingo_win>0);
}

static function bool SoundsEnabled(DXRFlags f)
{
    if(f.IsHordeMode()) return false;
    return (default.value==2) ||
           (default.value==4) ||
           (default.value==1 && f.IsBingoMode()) ||
           (default.value==1 && f.settings.bingo_win>0);
}

defaultproperties
{
    value=1
    defaultvalue=1
    HelpText="Should you be notified when a bingo goal has been failed or completed?"
    actionText="Bingo Notifications"
    enumText(0)="Bingo Messages & Sounds Disabled"
    enumText(1)="According to Game Mode"
    enumText(2)="Bingo Messages & Sounds Enabled"
    enumText(3)="Bingo Messages Enabled"
    enumText(4)="Bingo Sounds Enabled"
}
