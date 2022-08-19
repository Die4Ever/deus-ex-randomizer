//=============================================================================
// MenuScreenRandoOptions
//=============================================================================

class MenuScreenRandoOptions expands MenuUIScreenWindow;


event InitWindow()
{
    local int i;

    choices[i++]=Class'MenuChoice_Telemetry';

#ifdef vanilla
    choices[i++]=Class'MenuChoice_EnergyDisplay';
    choices[i++]=Class'MenuChoice_PasswordAutofill';
#endif
    choices[i++]=Class'MenuChoice_BrightnessBoost';

	Super.InitWindow();
}

// ----------------------------------------------------------------------
// SaveSettings()
// ----------------------------------------------------------------------

function SaveSettings()
{
	Super.SaveSettings();
	player.SaveConfig();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     actionButtons(0)=(Align=HALIGN_Right,Action=AB_Cancel)
     actionButtons(1)=(Align=HALIGN_Right,Action=AB_OK)
     actionButtons(2)=(Action=AB_Reset)
     Title="Randomizer Options"
     ClientWidth=500
     ClientHeight=200
     helpPosY=160
}
