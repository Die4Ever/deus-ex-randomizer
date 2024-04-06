//=============================================================================
// OATAugSelectorHighlight
//=============================================================================
class OATAugSelectorHighlight extends PersonaBorderButtonWindow;

var Color ColorWhite;

event DrawWindow(GC gc)
{
	GC.SetStyle(DSTY_Masked);
	
	//OAT notes: Set ColorWhite if you want your selector to be white and high contrast.
	//In my experience, this is not necessary. You can also just change the textures.
	GC.SetTileColor(ColButtonFace);
	//GC.SetTileColor(ColorWhite);
	GC.DrawTexture(0, 0, 42, 42, 0, 0, Texture'OATAugControllerAugHighlight');
}

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();
	
	SetSize(42, 42);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     ColorWhite=(R=255,G=255,B=255)
     
     Left_Textures(0)=(Tex=None,Width=0)
     Left_Textures(1)=(Tex=None,Width=0)
     Right_Textures(0)=(Tex=Texture'OATNextAugPageIcon',Width=42)
     Right_Textures(1)=(Tex=Texture'OATNextAugPageIcon',Width=42)
     Center_Textures(0)=(Tex=None,Width=0)
     Center_Textures(1)=(Tex=None,Width=0)
     
     buttonHeight=42
     minimumButtonWidth=42
}
