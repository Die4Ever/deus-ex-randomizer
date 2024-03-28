//=============================================================================
// MenuChoice_RandomMusic
//=============================================================================

class MenuChoice_RandomMusic extends DXRMenuUIChoiceInt;

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
    Super.SaveSetting();

    //If we want it to change music immediately,
    //any call to do so should happen here
}

static function bool IsEnabled(DXRFlags f)
{
    return (default.value==2) || (default.value==1 && !f.IsReducedRando());
}

defaultproperties
{
    value=1;
    defaultInfoWidth=243
    defaultInfoPosX=203
    HelpText="Randomize game music. This is automatically disabled for Zero Rando and Rando Lite modes."
    actionText="Randomize Music"
    enumText(0)="Normal Song Selection"
    enumText(1)="According to Game Mode"
    enumText(2)="Randomized Song Selection"
}
