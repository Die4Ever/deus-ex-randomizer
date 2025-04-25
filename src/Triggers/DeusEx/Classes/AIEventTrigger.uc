class AIEventTrigger extends Trigger;

var() name aiEventName;
var() EAIEventType aiEventType;
var() float volume; //Default gun volume is 2.0
var() float radius; //Default gun radius is 2.0 x 800 (volume x 800)

function Touch(Actor Other)
{
    Super.Touch(Other);

    if (IsRelevant(Other))
    {
        SendAIEvent(Other);
        if(bTriggerOnceOnly) Destroy();
    }
}

event Trigger( Actor Other, Pawn EventInstigator )
{
    SendAIEvent(Other);
    if(bTriggerOnceOnly) Destroy();
}

function SendAIEvent(Actor Other)
{
    Other.AISendEvent(aiEventName, aiEventType, volume, radius );
}


defaultproperties
{
    aiEventName=LoudNoise
    aiEventType=EAITYPE_Audio
    volume=1.0
    radius=128
    bCollideActors=false
    bCollideWorld=false
    bBlockActors=false
    bBlockPlayers=false
}
