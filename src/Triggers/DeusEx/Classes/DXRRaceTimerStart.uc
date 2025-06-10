class DXRRaceTimerStart extends Trigger;

var   int    numCheckPoints;
var   float  checkPointTimes[8];
var   float  startTime;
var   int    startHealth;
var   float  startEnergy;
var() float  targetTime;
var() string raceName;
var() string finishBingoGoal;  //Triggered when you finish the race
var() string targetBingoGoal;  //Triggered when you finish the race under the targetTime

var() bool   presentHealth; //Should we send health info in the telemetry message?
var() bool   presentEnergy; //Should we send energy info in the telemetry message?

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
    local #var(PlayerPawn) p;

    ResetCheckpoints();
    startTime = Level.TimeSeconds;

    p = #var(PlayerPawn)(GetPlayerPawn());
    if (presentHealth && startHealth==-1) {
        if (p!=None){
            startHealth=p.Health;
        }
    }
    if (presentEnergy && startEnergy==-1) {
        if (p!=None){
            startEnergy=p.Energy;
        }
    }

}

function RaceFinished()
{
    local #var(PlayerPawn) p;
    local float totalTime;
    local bool beatTarget;
    local int finalHealth,lostHealth;
    local float finalEnergy, lostEnergy;

    if (numCheckPoints<=0) return;

    totalTime = checkPointTimes[numCheckPoints-1] - startTime;

    beatTarget = (totalTime<targetTime);

    if (finishBingoGoal!=""){
        class'DXREvents'.static.MarkBingo(finishBingoGoal);
    }
    if (beatTarget && targetBingoGoal!=""){
        class'DXREvents'.static.MarkBingo(targetBingoGoal);
    }

    p = #var(PlayerPawn)(GetPlayerPawn());

    finalHealth=-1;
    finalEnergy=-1.0;
    lostHealth=0;
    lostEnergy=0.0;
    if (p!=None){
        finalHealth = p.Health;
        finalEnergy = p.Energy;
    }

    if (presentHealth && startHealth!=-1 && finalHealth!=-1){
        lostHealth = startHealth - finalHealth;
    }

    if (presentEnergy && startEnergy!=-1 && finalEnergy!=-1){
        lostEnergy = startEnergy - finalEnergy;
    }

    //Send a telemetry event
    class'DXREvents'.static.SendRaceTimerEvent(self,totalTime,lostHealth,lostEnergy);

    if (p!=None){
        //p.ClientMessage("Finished "$raceName$" in "$class'DXRInfo'.static.ConstructTimeStr(totalTime)$"!");
        if (beatTarget && class'MenuChoice_ToggleMemes'.static.IsEnabled(class'DXRando'.default.dxr.flags)){
            p.ClientMessage("Beat "$raceName$" in "$class'DXRInfo'.static.ConstructTimeStr(totalTime)$", under the target time of "$class'DXRInfo'.static.ConstructTimeStr(targetTime)$"!");
        }
    }
}

defaultproperties
{
    startTime=-1.0
    startHealth=-1
    startEnergy=-1.0
    checkPointTimes(0)=-1.0
    checkPointTimes(1)=-1.0
    checkPointTimes(2)=-1.0
    checkPointTimes(3)=-1.0
    checkPointTimes(4)=-1.0
    checkPointTimes(5)=-1.0
    checkPointTimes(6)=-1.0
    checkPointTimes(7)=-1.0
}
