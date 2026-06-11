class CreditsLeaderboardWindow extends Window;

var DXRStats stats;
var int numRuns;

const LEADERBOARD_LINE_HEIGHT = 25;

event InitWindow()
{
    SetSize(default.width, default.height);
}

function InitStats(DXRStats newstats)
{
    stats = newstats;
}

function ResizeLeaderboardWindow()
{
    local int newWinHeight, newNumRuns;

    if (stats==None) return;

    newNumRuns=stats.GetNumLeaderboardRuns();
    if (numRuns==newNumRuns) return;

    numRuns = newNumRuns;
    newWinHeight = (stats.GetNumLeaderboardRuns() + 1) * LEADERBOARD_LINE_HEIGHT; //25 per line, don't forget the header

    SetSize(default.width, newWinHeight);
}

event DrawWindow(GC gc)
{
    local color c;
    local int yPos;


    ResizeLeaderboardWindow();

    c.R = 255;
    c.G = 255;
    c.B = 255;
    gc.SetTextColor(c);

    gc.SetFont(Font'DXRFontConversationLargeBold');
    yPos = 0;
    gc.DrawText(0,yPos,100,50,"Name");
    gc.DrawText(250,yPos,150,50,"Score");
    gc.DrawText(350,yPos,100,50,"Real Time");
    gc.DrawText(450,yPos,100,50,"Flagshash");
    gc.DrawText(550,yPos,100,50,"Playthrough");

    if(stats != None)
        stats.DrawLeaderboard(gc);

    Super.DrawWindow(gc);
}

defaultproperties
{
    width=650
    height=400
}
