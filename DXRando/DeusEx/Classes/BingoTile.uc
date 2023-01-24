class BingoTile extends ButtonWindow;

var int progress, max;
var int bActiveMission;// 0==false, 1==maybe, 2==true

event DrawWindow(GC gc)
{
    local color c;
    local int progHeight;

    c.R = 255;
    c.G = 255;
    c.B = 255;
    SetTextColors(c, c, c, c, c, c);

    if(bActiveMission==2) {
        c.R = 80;
        c.G = 80;
        c.B = 80;
        gc.SetTileColor(c);
        gc.SetStyle(DSTY_Normal);
        gc.DrawPattern(0, 0, width, height, 0, 0, Texture'Solid');
    }
    else if(bActiveMission==1) {
        c.R = 48;
        c.G = 48;
        c.B = 48;
        gc.SetTileColor(c);
        gc.SetStyle(DSTY_Normal);
        gc.DrawPattern(0, 0, width, height, 0, 0, Texture'Solid');
    }
    else {
        c.R = 0;
        c.G = 0;
        c.B = 0;
        gc.SetTileColor(c);
        gc.SetStyle(DSTY_Normal);
        gc.DrawPattern(0, 0, width, height, 0, 0, Texture'Solid');

        c.R = 200;
        c.G = 200;
        c.B = 200;
        SetTextColors(c, c, c, c, c, c);
    }

    c.R = 30;
    c.G = 100;
    c.B = 30;
    gc.SetStyle(DSTY_Normal);
    gc.SetTileColor(c);
    progHeight = height * (float(progress)/float(max));
    gc.DrawPattern(0, height-progHeight, width, progHeight, 0, 0, Texture'Solid');

    Super.DrawWindow(gc);
}

simulated function SetProgress(int tprogress, int tmax, int tactiveMission)
{
    progress = tprogress;
    max = tmax;
    bActiveMission = tactiveMission;
}

//Bingo tiles don't need to handle any key presses
event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
	return false;
}
