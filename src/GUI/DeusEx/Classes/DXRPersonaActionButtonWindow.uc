class DXRPersonaActionButtonWindow extends PersonaActionButtonWindow;

event DrawWindow(GC gc)
{
    local color c;
    c.A = 255;
    gc.SetTileColor(c);
    gc.SetStyle(DSTY_Normal);
    gc.DrawPattern(0, 0, width, height, 0, 0, Texture'Solid');

    Super.DrawWindow(gc);
}
