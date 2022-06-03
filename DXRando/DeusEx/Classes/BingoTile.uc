class BingoTile extends ButtonWindow;

var int progress, max;

event DrawWindow(GC gc)
{
    local color c;
    local float p;

    c.R = 255;
    c.G = 255;
    c.B = 255;
    SetTextColors(c, c, c, c, c, c);

    c.R = 5;
    c.G = 5;
    c.B = 5;
    gc.SetTileColor(c);
    gc.SetStyle(DSTY_Normal);
    gc.DrawPattern(0, 0, width, height, 0, 0, Texture'Solid');

    c.R = 30;
    c.G = 100;
    c.B = 30;
    gc.SetStyle(DSTY_Normal);
    gc.SetTileColor(c);
    p = float(progress)/float(max);
    gc.DrawPattern(0, height*(1-p), width, height*p, 0, 0, Texture'Solid');

    Super.DrawWindow(gc);
}

simulated function SetProgress(int tprogress, int tmax)
{
    progress = tprogress;
    max = tmax;
}
