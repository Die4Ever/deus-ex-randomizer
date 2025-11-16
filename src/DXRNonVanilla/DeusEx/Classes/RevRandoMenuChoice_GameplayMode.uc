#compileif revision
class RevRandoMenuChoice_GameplayMode extends RevMenuChoice_GameplayMode;

function LoadSetting()
{
    Log( Self $ ".LoadSettings()" );

    LoadPaths();
    LoadOverrideLocalizationPaths();

    if (PathsContain("Shifter"))
        SetValue(1);
    else if (PathsContain("Biomod"))
        SetValue(2);
    else if (PathsContain("Vanilla"))
        SetValue(0); //No, fuck you.  Don't use Vanilla in Revision Rando.  Back to Normal!
    else if (PathsContain("HR"))
        SetValue(4);
    else // HuRen/Normal
        SetValue(0);

    OldValue = currentValue;

    if (HelpTexts[GetValue()] == "")
        HelpText = Default.HelpText;
    else
        HelpText = HelpTexts[GetValue()];
}

//We need to keep the numbering the same as in base Revision,
//but want to skip the "Vanilla" option normally present
function CycleNextValue()
{
    local int newValue;

    // Cycle to the next value, but make sure we don't exceed the
    // bounds of the enumText array.  If we do, start back at the
    // bottom.  Also skip past Vanilla...

    newValue = GetValue() + 1;

    if (newValue == arrayCount(enumText))
        newValue = 0;

    //Skip past vanilla
    if (enumText[newValue] == "Vanilla")
        newValue = newValue + 1;

    if (enumText[newValue] == "")
        newValue = 0;

    SetValue(newValue);
}
