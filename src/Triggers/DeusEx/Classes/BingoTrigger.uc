//=============================================================================
// BingoTrigger.
//=============================================================================
class BingoTrigger expands #var(prefix)Trigger;

var() String bingoEvent;
var() bool bDestroyOthers;
var() bool bUntrigger;
var() bool bPeepable;
var() bool bCrouchCheck;

var name FinishedFlag;
var int FinishedMax;

var() int touchLimit; //How many need to be touching the class proximity trigger to mark the bingo goal
var() int maxTouchReport; //The maximum number of items this trigger will report for class proximity

function Trigger(Actor Other, Pawn Instigator)
{
    if (DoBingoThing()){
        Super.Trigger(Other, Instigator);
    }
}

function Untrigger(Actor Other, Pawn Instigator)
{
    local bool shouldUntrigger;

    shouldUntrigger=True;
    if (bUntrigger){
        shouldUntrigger=DoBingoThing();
    }

    if (shouldUntrigger){
        Super.Untrigger(Other, Instigator);
    }
}

function Touch(Actor Other)
{

    if (TriggerType!=TT_Shoot && !bPeepable && !bCrouchCheck && IsRelevant(Other))
    {
        if (DoBingoThing()){
            Super.Touch(Other);
        }
    }
}

function Peep()
{
    if (bPeepable){
        DoBingoThing();
    }
}

function Timer()
{
    local #var(PlayerPawn) p;

    if (bCrouchCheck){
        foreach TouchingActors(class'#var(PlayerPawn)',p){
            if (p.bIsCrouching){
                DoBingoThing();
            }
        }
    }
}

function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, name damageType)
{
    if (TriggerType==TT_Shoot && instigatedBy.bIsPlayer)
	{
        DoBingoThing();
    }
}

function int GetSelfTouchCount()
{
    local Actor a;
    local int count;

    count = 0;

    foreach TouchingActors(ClassProximityType, a){
        count++;
    }

    //Cap the count at the maxTouchReport value
    count = Min(count,maxTouchReport);

    return count;
}

function int GetTouchingCount()
{
    local Actor a;
    local BingoTrigger bt;
    local int count;

    count=0;

    if (!bDestroyOthers) {
        //Count only THIS trigger
        count += GetSelfTouchCount();

        return count;
    }

    //Count the number in *all* the bingo triggers with the tag of the current trigger
    foreach AllActors(class'BingoTrigger',bt,Tag){
        //Note that this could mean you could have two triggers for different types of items with the same tag
        //Eg. Overlapping Skull and Femur triggers could allow a "bring X bones to this spot" goal, allowing a
        //mix of either class
        count+=bt.GetSelfTouchCount();
    }

    return count;

}

function bool DoBingoThing()
{
    local DXRando dxr;
    local BingoTrigger bt;

    if (bingoEvent==""){
        return false;
    }

    if (TriggerType==TT_ClassProximity && touchLimit>1){

        //Not enough items touching the bingo trigger
        if (GetTouchingCount() < touchLimit){
            return false;
        }
    }

    class'DXREvents'.static.MarkBingo(bingoEvent);

    FinishedMax--;
    if(FinishedMax == 0) {
        dxr = class'DXRando'.default.dxr;
        dxr.flagbase.SetBool(FinishedFlag, true,, 999);
    }

    if (bTriggerOnceOnly) {
        if (bDestroyOthers && Tag!=''){
            foreach AllActors(class'BingoTrigger',bt,Tag){
                bt.SelfDestruct();
            }
        } else {
            SelfDestruct();
        }
    }

    return true;
}

function SelfDestruct()
{
    bingoEvent = "";
    Destroy();
}

function MakeShootingTarget()
{
    TriggerType = TT_Shoot;
    bProjTarget=True;
    DamageThreshold=0;
}

function MakeClassProximityTrigger(class<Actor> className)
{
    TriggerType=TT_ClassProximity;
    ClassProximityType=className;
}

function MakePeepable()
{
    bPeepable=True;
    SetCollision(True,False,False);
}

function MakeCrouchChecker()
{
    bCrouchCheck=True; //bIsCrouching
    SetTimer(0.25,True);
}

function SetFinishedFlag(name NewFinishedFlag, int NewFinishedMax)
{
    FinishedFlag = NewFinishedFlag;
    FinishedMax = NewFinishedMax;
}

static function BingoTrigger Create(Actor a, Name bingoEvent, vector loc, optional float rad, optional float height)
{
    local BingoTrigger bt;

    bt = a.Spawn(class'BingoTrigger',,bingoEvent,loc); //Tag defaults to the bingoEvent name
    bt.bingoEvent = string(bingoEvent);

    if (rad!=0 && height!=0){
        bt.SetCollisionSize(rad,height); //You want collision
    } else {
        bt.SetCollision(False,False,False); //Disable collision, trigger only
    }

    return bt;

}

static function BingoTrigger PeepCreate(Actor a, Name bingoEvent, vector loc, float rad, float height)
{
    local BingoTrigger bt;

    bt = Create(a,bingoEvent,loc,rad,height);
    bt.MakePeepable();

    return bt;
}

static function BingoTrigger ProxCreate(Actor a, Name bingoEvent, vector loc, float rad, float height, class<Actor> className, optional int touchCount, optional int maxTouchReport)
{
    local BingoTrigger bt;

    bt = Create(a,bingoEvent,loc,rad,height);
    bt.MakeClassProximityTrigger(className);

    if (touchCount>0){
        bt.touchLimit = touchCount;
    }

    if (maxTouchReport>0){
        //Defaults to 100
        bt.maxTouchReport = maxTouchReport;
    }

    return bt;
}

static function BingoTrigger ShootCreate(Actor a, Name bingoEvent, vector loc, float rad, float height)
{
    local BingoTrigger bt;

    bt = Create(a,bingoEvent,loc,rad,height);
    bt.MakeShootingTarget();

    return bt;
}

static function BingoTrigger CrouchCreate(Actor a, Name bingoEvent, vector loc, float rad, float height)
{
    local BingoTrigger bt;

    bt = Create(a,bingoEvent,loc,rad,height);
    bt.MakeCrouchChecker();

    return bt;
}


defaultproperties
{
     bingoEvent=""
     bTriggerOnceOnly=True
     bDestroyOthers=True
     bUntrigger=False
     bPeepable=False
     bCrouchCheck=False
     touchLimit=-1
     maxTouchReport=100
}
