class DXRBartender injects #var(prefix)Bartender;

var float lastConTime;

function EnterConversationState(bool bFirstPerson, optional bool bAvoidState)
{
    Super.EnterConversationState(bFirstPerson, bAvoidState);
    lastConTime = Level.TimeSeconds;
}

function Frob(actor Frobber, Inventory frobWith)
{
    lastConTime = 0.0;
    Super.Frob(Frobber, frobWith);
}

function bool CanConverse()
{
    return Super.CanConverse() && (lastConTime == 0.0 || Level.TimeSeconds - lastConTime > 30.0);
}
