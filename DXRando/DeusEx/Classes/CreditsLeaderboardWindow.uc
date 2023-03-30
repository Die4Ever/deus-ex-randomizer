class CreditsLeaderboardWindow extends Window;

var DXRStats stats;

event InitWindow()
{
    SetSize(default.width, default.height);
}

function InitStats(DXRStats newstats)
{
    stats = newstats;
}

event DrawWindow(GC gc)
{
    local color c;
    local float p;
    local int i, yPos;

    c.R = 255;
    c.G = 255;
    c.B = 255;
    gc.SetTextColor(c);

    gc.SetFont(Font'DeusExUI.FontConversationLargeBold');
    yPos = 0;
    gc.DrawText(0,yPos,100,50,"Name");
    gc.DrawText(250,yPos,150,50,"Score");
    gc.DrawText(350,yPos,100,50,"Real Time");
    gc.DrawText(450,yPos,100,50,"Flagshash");

    if(stats != None)
        stats.DrawLeaderboard(gc);

    Super.DrawWindow(gc);
}

defaultproperties
{
    width=550
    height=400
}
