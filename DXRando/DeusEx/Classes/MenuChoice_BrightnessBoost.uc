//=============================================================================
// MenuChoice_BrightnessBoost
//=============================================================================

class MenuChoice_BrightnessBoost extends MenuUIChoiceSlider;

var config int BrightnessBoost;

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
	saveValue = BrightnessBoost;
    SetValue(saveValue);
}

// ----------------------------------------------------------------------
// CancelSetting()
// ----------------------------------------------------------------------

function CancelSetting()
{
	BrightnessBoost = saveValue;
    AdjustBrightness(BrightnessBoost);
	SaveConfig();
}

// ----------------------------------------------------------------------
// ResetToDefault()
// ----------------------------------------------------------------------

function ResetToDefault()
{
	BrightnessBoost = int(defaultValue);
    SetValue(BrightnessBoost);
    AdjustBrightness(BrightnessBoost);
    SaveConfig();
}

function SetEnumerators()
{
    local int i;

    for (i=0;i<numTicks;i++){
	    SetEnumeration(i, string(i));
    }
}

function AdjustBrightness(int newVal)
{
    class'DXRFixup'.static.AdjustBrightness(player,newVal);
}

// ----------------------------------------------------------------------
// ScalePositionChanged() : Called when an ancestor scale window's
//                          position is moved
// ----------------------------------------------------------------------

event bool ScalePositionChanged(Window scale, int newTickPosition,
                                float newValue, bool bFinal)
{
	// Don't do anything while initializing as we get several
	// ScalePositionChanged() events before LoadSetting() is called.

	if (bInitializing)
		return False;

	BrightnessBoost = int(GetValue());

    if(bFinal){
	    AdjustBrightness(BrightnessBoost);
        SaveConfig();
    }

	return false;
}

function CreateActionButton()
{
    Super.CreateActionButton();
    SetActionButtonWidth(179);
}

function float GetValue()
{
    return int(Super.GetValue());
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     numTicks=256
     startValue=0
     endValue=256
     defaultValue=15
     choiceControlPosX=203
     actionText="Brightness Boost"
     HelpText="Generally increases brightness for ease of play"
}
