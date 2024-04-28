//=============================================================================
// BarkBindTrigger.
//=============================================================================
class BarkBindTrigger expands Trigger;

var() bool bDestroyOthers;
var() string newBindName;

function Touch(Actor Other)
{
    Super.Touch(Other);

    if (IsRelevant(Other))
    {
        BindBarkNameEvent();
    }
}

function Trigger(Actor Other, Pawn Instigator)
{
    Super.Trigger(Other, Instigator);
    BindBarkNameEvent();
}

function BindBarkNameEvent()
{
    local DXRando dxr;
    local ScriptedPawn a;

    foreach AllActors(class'ScriptedPawn',a,event)
    {
        a.BarkBindName=newBindName;
        a.ConBindEvents();
    }

    SelfDestruct();

}

function SelfDestruct()
{
    event = '';
    newBindName = "";
    Destroy();
}

static function BarkBindTrigger Create(Actor a, name targetEvent, string NewBindName, vector loc, float rad, float height)
{
    local BarkBindTrigger bbt;

    bbt = a.Spawn(class'BarkBindTrigger',,,loc);
    bbt.newBindName = NewBindName;
    bbt.Event=targetEvent;

    bbt.SetCollisionSize(rad,height); //You want collision

    return bbt;

}

defaultproperties
{
    TriggerType=TT_PlayerProximity
}
