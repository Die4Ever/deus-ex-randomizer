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
    choices[i++]=Class'MenuChoice_ShowKeys';
#endif
    choices[i++]=Class'MenuChoice_BrightnessBoost';

    //Automatic sizing to the number of entries...
    ClientHeight = (i+1) * 40;
    helpPosY = ClientHeight - 40;

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
     ClientHeight=50
     helpPosY=10
}
