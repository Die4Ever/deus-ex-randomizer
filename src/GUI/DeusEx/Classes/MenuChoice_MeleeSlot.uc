//=============================================================================
// MenuChoice_MeleeSlot
//=============================================================================

class MenuChoice_MeleeSlot extends MenuUIChoiceSlider config(DXRandoOptions);

var config int StartingMeleeSlot;

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
	saveValue = float(StartingMeleeSlot);
    SetValue(saveValue);
}

// // ----------------------------------------------------------------------
// // CancelSetting()
// // ----------------------------------------------------------------------

function CancelSetting()
{
	StartingMeleeSlot = int(saveValue);
	SaveConfig();
}

// // ----------------------------------------------------------------------
// // ResetToDefault()
// // ----------------------------------------------------------------------

function ResetToDefault()
{
    StartingMeleeSlot = int(defaultValue);
    SetValue(defaultValue);
    SaveConfig();
}

function SetEnumerators()
{
	local int enumIndex;

	for (enumIndex = 0; enumIndex < 9; enumIndex++) {
		SetEnumeration(enumIndex, enumIndex + 1);
    }
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

	StartingMeleeSlot = int(GetValue());

    if(bFinal){
        SaveConfig();
    }

	return false;
}

function CreateActionButton()
{
    Super.CreateActionButton();
    SetActionButtonWidth(179);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
    numTicks=9
    startValue=0
    endValue=8
    defaultValue=1
    StartingMeleeSlot=1
    choiceControlPosX=203
    actionText="Starting Melee Belt Slot"
    HelpText="Which belt slot your starting melee weapon gets put on."
}
