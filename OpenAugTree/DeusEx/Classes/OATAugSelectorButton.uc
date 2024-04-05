//=============================================================================
// OATAugSelectorButton
//=============================================================================
class OATAugSelectorButton extends PersonaBorderButtonWindow;

//MADDERS, 8/26/23: I get really damn tired of having to define 2x as many default properties.
struct OATButtonPos {
	var int X;
	var int Y;
};

//OAT notes: Passive and PassiveDisabled are VMD stuff.
//Re-enable them and change colors if you have passive augs in your mod.
var Color AugColor, ColorOff, ColorOn, ColorPassive, ColorPassiveDisabled;
var Texture AugIcon;
var OATButtonPos SublayerOffset;

var Augmentation CurAug;

//OAT: Barf. This was used for my purposes to reduce casting calls.
//Unlikely you'll need this, but if you have a similar buffer aug, knock yourself out.
//var VMDBufferAugmentation VAug;

function SetAugmentation(Augmentation NewAug)
{
	CurAug = NewAug;
	//VAug = VMDBufferAugmentation(NewAug);
	
	if (CurAug != None)
	{
		AugIcon = CurAug.SmallIcon;
	}
	UpdateAugColor();
}

function UpdateAugColor()
{
	//OAT: Not used for vanilla augs. Disabled for now.
	/*if ((VAug != None) && (VAug.bPassive))
	{
		if (VAug.bDisabled)
		{
			AugColor = ColorPassiveDisabled;
		}
		else
		{
			AugColor = ColorPassive;
		}
	}
	else */if (CurAug != None)
	{
		if (CurAug.bIsActive)
		{
			AugColor = ColorOn;
		}
		else
		{
			AugColor = ColorOff;
		}
	}
}

event DrawWindow(GC gc)
{
	GC.SetStyle(DSTY_Masked);
	
	if (CurAug != None)
	{
		GC.SetTileColor(AugColor);
		GC.DrawTexture(SublayerOffset.X, SublayerOffset.Y, 32, 32, 0, 0, AugIcon);
	}
	
	GC.SetTileColor(ColButtonFace);
	GC.DrawTexture(0, 0, 36, 36, 0, 0, Texture'OATAugControllerAugCase');
}

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();
	
	SetSize(36, 36);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     ColorOff=(R=255,G=255,B=255)
     ColorOn=(R=255,G=255,B=0)
     ColorPassive=(R=192,G=255,B=96)
     ColorPassiveDisabled=(R=255,G=96,B=96)
     SublayerOffset=(X=2,Y=2)
     
     Left_Textures(0)=(Tex=None,Width=0)
     Left_Textures(1)=(Tex=None,Width=0)
     Right_Textures(0)=(Tex=Texture'OATNextAugPageIcon',Width=36)
     Right_Textures(1)=(Tex=Texture'OATNextAugPageIcon',Width=36)
     Center_Textures(0)=(Tex=None,Width=0)
     Center_Textures(1)=(Tex=None,Width=0)
     
     buttonHeight=36
     minimumButtonWidth=36
}
