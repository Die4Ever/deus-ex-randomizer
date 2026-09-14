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

    activeItems.Destroy();
    activeItems = HUDActiveItemsDisplay(NewChild(Class'DXRHUDActiveItemsDisplay'));
    activeItems.SetWindowAlignments(HALIGN_Full, VALIGN_Full);
#endif

#ifndef vmd||hx
    augDisplay.Destroy();
    augDisplay = AugmentationDisplayWindow(NewChild(Class'DXRAugDisplayWindow'));
    augDisplay.SetWindowAlignments(HALIGN_Full, VALIGN_Full);
#endif

}

#ifdef gmdxae
//Hide the central crosshair if the aim laser is active (third person or fixed cameras)
function UpdateCrosshair(DeusExPlayer player)
{
    local LaserEmitter laser;

    Super.UpdateCrosshair(player);

    laser = #var(PlayerPawn)(Player).aimLaser; //GMDX:AE is always using the GMDXAERandoPlayer class
    if (laser!=None){
        //Disable the main crosshair if the aim laser is active
        cross.SetCrosshair(False);
    }

}
#endif
