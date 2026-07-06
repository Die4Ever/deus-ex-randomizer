class MenuChoice_ShowBingoBoard extends MenuChoice_AccordingToGameMode;

static function bool IsEnabled()
{
    local DXRFlags f;

    f = DXRFlags(class'DXRFlags'.static.Find());
    if (f==None) return (default.value==2);

    if(f.IsHordeMode()) return false; //Don't show in Horde Mode
    if(f.IsBingoMode()) return true;  //Always show in bingo modes

    //"According to Game Mode" will be disabled in Zero Rando (Plus), on otherwise
    return (default.value==2) || (default.value==1 && !f.IsZeroRando());
}

defaultproperties
{
    HelpText="Should the bingo board be available to view?"
    actionText="Bingo Board"
}
