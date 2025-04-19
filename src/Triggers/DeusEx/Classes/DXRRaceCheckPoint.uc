class DXRRaceCheckPoint extends Trigger;

var DXRRaceTimerStart startPoint;
var int checkPointNum;


function Touch(Actor Other)
{
    if (IsRelevant(Other)){
        HitStartPoint();
    }
}

function Trigger(Actor Other, Pawn Instigator)
{
    HitStartPoint();
}

function HitStartPoint()
{
    if (startPoint==None) return;
    if (checkPointNum<0) return;

    startPoint.HitCheckpoint(self);
}

defaultproperties
{
    checkPointNum=-1
}
