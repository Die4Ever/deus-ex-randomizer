//=============================================================================
// OATAugSelectorCellIcon
//=============================================================================
class OATAugSelectorCellIcon extends Window;

var Texture CellIcon;

//OAT, 2/25/25: We did some work here so this stretches, so we can bullshit the dimensions to our consistent format... Doesn't look bad, either.
event DrawWindow(GC gc)
{
	GC.SetStyle(DSTY_Masked);
	GC.DrawStretchedTexture(0, 0, 52, 52, 0, 0, 64, 64, CellIcon);
}

event InitWindow()
{
	Super.InitWindow();
	SetSize(33, 33);
}

defaultproperties
{
    CellIcon=Texture'BeltIconBioCell'
}
