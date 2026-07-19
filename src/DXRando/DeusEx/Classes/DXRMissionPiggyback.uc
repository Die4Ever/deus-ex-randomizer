class DXRMissionPiggyback extends Info;

var MissionScript baseScript;
var float checkTime;

function Init(MissionScript orig)
{
    baseScript = orig;
    checkTime = orig.checkTime / 4; //Check more frequently than the base script

    SetTimer(checkTime,True);
}

function Timer();
