class ScopeView injects DeusExScopeView;

event DrawWindow(GC gc)
{
    local float			fromX, toX;
    local float			fromY, toY;
    local float			scopeWidth, scopeHeight;

    Super(Window).DrawWindow(gc);

    if (GetRootWindow().parentPawn != None)
    {
        if (player.IsInState('Dying'))
            return;
    }

    // Figure out where to put everything
    if (bBinocs)
        scopeWidth  = 512;
    else
        scopeWidth  = 256;

    scopeHeight = 256;

    fromX = (width-scopeWidth)/2;
    fromY = (height-scopeHeight)/2;
    toX   = fromX + scopeWidth;
    toY   = fromY + scopeHeight;

    if (bBinocs)
    {
        gc.SetTileColor(colLines);
        gc.SetStyle(DSTY_Masked);
        gc.DrawTexture(fromX,       fromY, 256, scopeHeight, 0, 0, Texture'HUDBinocularCrosshair_1');
        gc.DrawTexture(fromX + 256, fromY, 256, scopeHeight, 0, 0, Texture'HUDBinocularCrosshair_2');
    }
    else
    {
        gc.SetStyle(DSTY_Modulated);
        gc.DrawTexture(fromX, fromY, scopeWidth, scopeHeight, 0, 0, Texture'HUDScopeView2');
    }
}
