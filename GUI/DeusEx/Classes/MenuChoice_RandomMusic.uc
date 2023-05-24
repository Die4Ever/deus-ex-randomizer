//=============================================================================
// MenuChoice_RandomMusic
//=============================================================================

class MenuChoice_RandomMusic extends DXRMenuUIChoiceBool;

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
    Super.SaveSetting();

    //If we want it to change music immediately,
    //any call to do so should happen here
}

defaultproperties
{
    enabled=True;
    defaultInfoWidth=243
    defaultInfoPosX=203
    HelpText="Randomize game music. This is automatically disabled for Zero Rando and Rando Lite modes."
    actionText="Randomize Music"
    enumText(0)="Not Random"
    enumText(1)="Random"
}
