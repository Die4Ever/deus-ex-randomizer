//=============================================================================
// MenuChoice_Telemetry
//=============================================================================

class MenuChoice_Telemetry extends MenuUIChoiceEnum;

var DXRTelemetry t;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{

    Super.InitWindow();

    foreach player.AllActors(class'DXRTelemetry', t) { break; }
    if( t == None ) t = player.Spawn(class'DXRTelemetry');
    t.CheckConfig();

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

    enumText[0] = "Disabled";
    enumText[1] = "Enabled, Death Markers Hidden";
    enumText[2] = "All Enabled";
}

// ----------------------------------------------------------------------
// SetInitialCycleType()
// ----------------------------------------------------------------------

function SetInitialOption()
{
    if(t.enabled && t.death_markers)
        SetValue(2);
    else if(t.enabled)
        SetValue(1);
    else
        SetValue(0);

}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
   switch(currentvalue){
       case 2:
           t.set_enabled(True,True);
           break;
       case 1:
           t.set_enabled(True,False);
           break;
       case 0:
           t.set_enabled(False,False);
           break;
   }
}

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
    if(t.enabled && t.death_markers)
        SetValue(2);
    else if(t.enabled)
        SetValue(1);
    else
        SetValue(0);
}

// ----------------------------------------------------------------------
// ResetToDefault
// ----------------------------------------------------------------------

function ResetToDefault()
{
   t.set_enabled(False,False);
   LoadSetting();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
    defaultInfoWidth=243
    defaultInfoPosX=203
    HelpText="Death Markers, send error reports, and get notified about updates!"
    actionText="Online Features"
}
