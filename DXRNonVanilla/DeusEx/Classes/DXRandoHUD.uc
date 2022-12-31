#ifdef revision
class DXRandoHUD extends RevHUD;
#else
class DXRandoHUD extends DeusExHUD;
#endif

event InitWindow()
{
	Super.InitWindow();

#ifndef vmd
    frobDisplay.Destroy();
	frobDisplay = FrobDisplayWindow(NewChild(Class'DXRFrobDisplayWindow'));
	frobDisplay.SetWindowAlignments(HALIGN_Full, VALIGN_Full);
#endif
}
