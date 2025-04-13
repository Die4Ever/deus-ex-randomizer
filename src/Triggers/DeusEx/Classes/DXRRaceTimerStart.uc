class DXRRaceTimerStart extends Trigger;

var   int    numCheckPoints;
var   float  checkPointTimes[8];
var   float  startTime;
var() float  targetTime;
var() string raceName;
var() string finishBingoGoal;  //Triggered when you finish the race
var() string targetBingoGoal;  //Triggered when you finish the race under the targetTime

function RegisterCheckpoint(DXRRaceCheckPoint checkpoint)
{
    if (numCheckPoints>=ArrayCount(checkPointTimes)){
        //Failure
        return;
    }
    checkpoint.checkPointNum=numCheckPoints++;
    checkpoint.startPoint=self;
}

function ResetCheckpoints()
{
    local int i;

    for (i=0;i<ArrayCount(checkPointTimes);i++){
        checkPointTimes[i]=-1;
    }

    startTime=-1;
}

function HitCheckpoint(DXRRaceCheckPoint checkpoint)
{
    local int i;

    if (startTime<0) return; //Haven't hit the start point yet

    if (checkPointTimes[checkpoint.checkPointNum]>=0) return; //This checkpoint has already been hit

    //Check if all previous checkpoints were hit
    for(i=0;i<checkpoint.checkPointNum;i++){
        if (checkPointTimes[checkpoint.checkPointNum]<0) return; //Missed an earlier checkpoint
    }

    checkPointTimes[checkpoint.checkPointNum]=Level.TimeSeconds;

    if ((checkpoint.checkPointNum+1)==numCheckPoints){
        RaceFinished();
    }

}

function Touch(Actor Other)
{
    if (IsRelevant(Other)){
        StartRaceTimer();
    }
}

function Trigger(Actor Other, Pawn Instigator)
{
    StartRaceTimer();
}

function StartRaceTimer()
{
    ResetCheckpoints();
    startTime = Level.TimeSeconds;
}

function RaceFinished()
{
    local #var(PlayerPawn) p;
    local float totalTime;
    local bool beatTarget;

    if (numCheckPoints<=0) return;

    totalTime = checkPointTimes[numCheckPoints-1] - startTime;

    beatTarget = (totalTime<targetTime);

    if (finishBingoGoal!=""){
        class'DXREvents'.static.MarkBingo(finishBingoGoal);
    }
    if (beatTarget && targetBingoGoal!=""){
        class'DXREvents'.static.MarkBingo(targetBingoGoal);
    }

    //Send a telemetry event
    class'DXREvents'.static.SendRaceTimerEvent(self,totalTime);

    p = #var(PlayerPawn)(GetPlayerPawn());
    if (p!=None){
        //p.ClientMessage("Finished "$raceName$" in "$class'DXRInfo'.static.FloatToString(totalTime,3)$" seconds!");
        if (beatTarget && class'MenuChoice_ToggleMemes'.static.IsEnabled(class'DXRando'.default.dxr.flags)){
            p.ClientMessage("Beat "$raceName$" in "$class'DXRInfo'.static.FloatToString(totalTime,3)$" seconds, under the target time of "$class'DXRInfo'.static.FloatToString(targetTime,3)$" seconds!");
        }
    }

}

defaultproperties
{
    checkPointTimes(0)=-1.0
    checkPointTimes(1)=-1.0
    checkPointTimes(2)=-1.0
    checkPointTimes(3)=-1.0
    checkPointTimes(4)=-1.0
    checkPointTimes(5)=-1.0
    checkPointTimes(6)=-1.0
    checkPointTimes(7)=-1.0
}
