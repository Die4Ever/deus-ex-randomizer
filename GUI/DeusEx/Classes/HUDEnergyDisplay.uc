//=============================================================================
// HUDEnergyDisplay
//=============================================================================
class HUDEnergyDisplay expands HUDBaseWindow;

var DeusExPlayer	player;

var TextWindow      text;
var Font            textfont;

// Defaults
var Texture texBackground;
var Texture texBorder;

var bool hideMeter;

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();

	Hide();

	player = DeusExPlayer(DeusExRootWindow(GetRootWindow()).parentPawn);

	SetSize(73, 40);
    bTickEnabled = True;
	CreateEnergyWindow();
    StyleChanged();
}

// ----------------------------------------------------------------------
// Tick()
//
// Used to update the energy consumption
//
// ----------------------------------------------------------------------

event Tick(float deltaSeconds)
{
    local float energyUse;

    energyUse = GetTotalEnergyUse();
    text.SetText(
        class'DXRInfo'.static.FloatToString(energyUse,3) $ " / Sec|n"
        $ class'DXRInfo'.static.FloatToString(GetEnergyTimeRemaining(energyUse),1)$" sec left"
    );

    SetVisibility(!hideMeter && energyUse>0);
}

function float GetEnergyTimeRemaining(float energyUse)
{
    return player.Energy / energyUse;
}

function float GetTotalEnergyUse()
{
	local float energyUse, energyMult;
	local Augmentation anAug;
    local Augmentation PowerAug;

	energyUse = 0;
	energyMult = 1.0;

    if(player == None || player.AugmentationSystem == None)
        return 0;

	anAug = player.AugmentationSystem.FirstAug;
	while(anAug != None)
	{
        if (anAug.IsA('AugPower'))
            PowerAug = anAug;
	    if (anAug.bHasIt && anAug.bIsActive)
		{
			energyUse += ((anAug.GetEnergyRate()/60));
		    if (anAug.IsA('AugPower'))
            {
			    energyMult = anAug.LevelValues[anAug.CurrentLevel];
            }
		}
		anAug = anAug.next;
    }

    if (PowerAug.bIsActive)
        energyMult = PowerAug.LevelValues[PowerAug.CurrentLevel];

    return energyUse * energyMult;
}

// ----------------------------------------------------------------------
// VisibilityChanged()
// ----------------------------------------------------------------------

event VisibilityChanged(bool bNewVisibility)
{
}

// ----------------------------------------------------------------------
// PostDrawWindow()
// ----------------------------------------------------------------------

function PostDrawWindow(GC gc)
{
	PostDrawBackground(gc);
}

// ----------------------------------------------------------------------
// PostDrawBackground()
// ----------------------------------------------------------------------

function DrawBackground(GC gc)
{
	gc.SetStyle(backgroundDrawStyle);
	gc.SetTileColor(colBackground);
	gc.DrawTexture(11, 6, 60, 19, 0, 0, texBackground);
}

// ----------------------------------------------------------------------
// PostDrawBackground()
// ----------------------------------------------------------------------

function PostDrawBackground(GC gc)
{
	gc.SetTileColor(colBackground);
	gc.SetStyle(DSTY_Masked);
}

// ----------------------------------------------------------------------
// PostDrawBorder()
// ----------------------------------------------------------------------

function DrawBorder(GC gc)
{
	if (bDrawBorder)
	{
		gc.SetStyle(borderDrawStyle);
		gc.SetTileColor(colBorder);
		gc.DrawTexture(0, 0, 73, 40, 0, 0, texBorder);
	}
}

// ----------------------------------------------------------------------
// CreateEnergyWindow()
// ----------------------------------------------------------------------

function CreateEnergyWindow()
{
    local Color colName;
    local ColorTheme theme;

    theme = player.ThemeManager.GetCurrentHUDColorTheme();
    colName = theme.GetColorFromName('HUDColor_NormalText');

    text = TextWindow(NewChild(Class'TextWindow'));
    text.SetFont(textfont);
    text.SetTextColor(colName);
    text.SetLines(2,2);
    text.SetTextAlignments(HALIGN_Center,VALIGN_Center);
    text.SetText("");
    text.SetPos(14,1);
}

// ----------------------------------------------------------------------
// StyleChanged()
// ----------------------------------------------------------------------

event StyleChanged()
{
	local ColorTheme theme;
    local Color colName;

	Super.StyleChanged();

    if (text!=None){
	    theme = player.ThemeManager.GetCurrentHUDColorTheme();
	    colName   = theme.GetColorFromName('HUDColor_NormalText');
        text.SetTextColor(colName);
    }

    //Look up whether we should always be hidden or not
    if(player!=None){
        hideMeter = IsDisabled();
    }
}

// ----------------------------------------------------------------------
// SetVisibility()
// ----------------------------------------------------------------------

function SetVisibility( bool bNewVisibility )
{
	Show( bNewVisibility );
}


function bool IsDisabled()
{
    return class'MenuChoice_EnergyDisplay'.default.bEnergyDisplayHidden;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
    texBackground=Texture'DeusExUI.UserInterface.HUDCompassBackground_1'
    texBorder=Texture'DeusExUI.UserInterface.HUDCompassBorder_1'
    textfont=Font'FontTiny';
}
