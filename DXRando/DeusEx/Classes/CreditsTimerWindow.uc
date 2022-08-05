class CreditsTimerWindow extends Window;

struct MissionTimeInfo
{
    var string MissionNum;
    var string MissionName;
    var string SuccessTime;
    var string CompleteTime;
};

var MissionTimeInfo mission_times[20];

function AddMissionTime(string missionNum, string missionName, string successTime, string completeTime)
{
    local int i;
    i=0;
    while(mission_times[i].MissionName!=""){i++;};

    mission_times[i].MissionNum = missionNum;
    mission_times[i].MissionName = missionName;
    mission_times[i].SuccessTime = successTime;
    mission_times[i].CompleteTime = completeTime;
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
    gc.DrawText(0,yPos,100,50,"Mission");
    gc.DrawText(235,yPos,150,50,"In-Game Time");
    gc.DrawText(350,yPos,100,50,"Real Time");

    gc.SetFont(Font'DeusExUI.FontConversationLarge');
    while(mission_times[i].MissionName!=""){
        yPos = (i+1) * 25;
        gc.DrawText(0,yPos,100,50,mission_times[i].MissionNum);
        gc.DrawText(25,yPos,200,50,mission_times[i].MissionName);
        gc.DrawText(250,yPos,100,50,mission_times[i].SuccessTime);
        gc.DrawText(350,yPos,100,50,mission_times[i].CompleteTime);
        i++;
    }

    Super.DrawWindow(gc);
}
