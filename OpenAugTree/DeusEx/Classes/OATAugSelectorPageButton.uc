//=============================================================================
// OATAugSelectorPageButton
//=============================================================================
class OATAugSelectorPageButton extends PersonaBorderButtonWindow;

//MADDERS, 8/26/23: I get really damn tired of having to define 2x as many default properties.
struct OATButtonPos {
	var int X;
	var int Y;
};

var Color ColorWhite;
var Texture FakeAugIcon;
var OATButtonPos SublayerOffset;

function SetFakeIcon(Texture NewIcon)
{
	if (NewIcon != None)
	{
		FakeAugIcon = NewIcon;
	}
}

event DrawWindow(GC gc)
{
	GC.SetStyle(DSTY_Masked);
	
	if (FakeAugIcon != None)
	{
		GC.SetTileColor(ColorWhite);
		GC.DrawTexture(SublayerOffset.X, SublayerOffset.Y, 32, 32, 0, 0, FakeAugIcon);
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
     ColorWhite=(R=255,G=255,B=255)
     
     Left_Textures(0)=(Tex=None,Width=0)
     Left_Textures(1)=(Tex=None,Width=0)
     Right_Textures(0)=(Tex=Texture'OATNextAugPageIcon',Width=36)
     Right_Textures(1)=(Tex=Texture'OATNextAugPageIcon',Width=36)
     Center_Textures(0)=(Tex=None,Width=0)
     Center_Textures(1)=(Tex=None,Width=0)
     SublayerOffset=(X=2,Y=2)
     
     buttonHeight=36
     minimumButtonWidth=36
}
