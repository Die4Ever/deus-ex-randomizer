class BingoTile extends ButtonWindow;

var int progress, max;
var int bActiveMission;// 0==false, 1==maybe, 2==true

event DrawWindow(GC gc)
{
    local color c;
    local int progHeight;

    //trigger a compiler error so we remember to choose some different appearance for activeMission vs not

    c.R = 255;
    c.G = 255;
    c.B = 255;
    SetTextColors(c, c, c, c, c, c);

    if(bActiveMission==2) {
        c.R = 50;
        c.G = 50;
        c.B = 50;
        gc.SetTileColor(c);
        gc.SetStyle(DSTY_Normal);
        gc.DrawPattern(0, 0, width, height, 0, 0, Texture'Solid');
    }
    else if(bActiveMission==1) {
        c.R = 10;
        c.G = 10;
        c.B = 10;
        gc.SetTileColor(c);
        gc.SetStyle(DSTY_Normal);
        gc.DrawPattern(0, 0, width, height, 0, 0, Texture'Solid');
    }
    else {
        c.R = 1;
        c.G = 1;
        c.B = 1;
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
