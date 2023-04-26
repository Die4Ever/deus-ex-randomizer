//=============================================================================
// MenuChoice_RandomMusic
//=============================================================================

class MenuChoice_RandomMusic extends MenuUIChoiceEnum;

var config bool random_music;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
    Super.InitWindow();

    PopulateOptions();

    SetInitialOption();

    SetActionButtonWidth(179);
}

// ----------------------------------------------------------------------
// PopulateCycleTypes()
// ----------------------------------------------------------------------

function PopulateOptions()
{
    local int typeIndex;

    enumText[0] = "Not Random";
    enumText[1] = "Random";
}

// ----------------------------------------------------------------------
// SetInitialCycleType()
// ----------------------------------------------------------------------

function SetInitialOption()
{
    SetValue(int(random_music));
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
    random_music = bool(GetValue());

    //If we want it to change music immediately,
    //any call to do so should happen here

    SaveConfig();
}

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
    SetValue(int(random_music));
}

// ----------------------------------------------------------------------
// ResetToDefault
// ----------------------------------------------------------------------

function ResetToDefault()
{
    random_music = default.random_music;
    SetValue(int(random_music));
    SaveSetting();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     random_music=True;
     defaultInfoWidth=243
     defaultInfoPosX=203
     HelpText="Randomize game music"
     actionText="Randomize Music"
}
