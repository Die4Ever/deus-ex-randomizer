class BingoTile extends ButtonWindow;

var int progress, max;
var string event;
var string helpText;
var int missions;
var int bActiveMission;// -1==impossible, 0==false, 1==maybe, 2==true
var bool isCredits;

event DrawWindow(GC gc)
{
    local color c;
    local int progHeight;

    c.R = 255;
    c.G = 255;
    c.B = 255;
    SetTextColors(c, c, c, c, c, c);

    if(isCredits) {
        c.R = 10;
        c.G = 10;
        c.B = 10;
        gc.SetTileColor(c);
        gc.SetStyle(DSTY_Normal);
        gc.DrawPattern(0, 0, width, height, 0, 0, Texture'Solid');
    }
    else if(bActiveMission==2) {
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
    else if(bActiveMission==-1) {
        c.R = 30;
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

simulated function SetHelpText(string event, int mission, bool FemJC)
{
    self.event = event;
    helpText = class'DXREvents'.static.GetBingoGoalHelpText(event,mission,FemJC);
}

simulated function string GenerateMissionString()
{
    local int i,t,num;
    local string msg;

    if (missions==0){
        return "Missions: All";
    }

    msg="";
    for (i=1;i<=15;i++){
        t=(1<<i) & missions;
        if (t!=0){
            msg=msg$i$", ";
            num++;
        }
    }

    msg = Left(msg,len(msg)-2);
    if(num>1){
        msg="Missions: "$msg;
    } else {
        msg="Mission: "$msg;
    }

    return msg;
}

simulated function string GetHelpText()
{
    local string helpmsg;

    helpmsg=helpText;

    //Display the list of missions the goal is possible in...
    helpmsg=helpmsg$"|n|n"$GenerateMissionString();

    if (max>1){
        helpmsg=helpmsg$"|n";
        helpmsg=helpmsg$"Progress: "$progress$"/"$max;
    }

    return helpmsg;
}

simulated function SetMissions(int missionmask)
{
    missions = missionmask;
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
