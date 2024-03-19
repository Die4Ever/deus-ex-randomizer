class DXRBartender injects #var(prefix)Bartender;

var float realLastConEndTime;

function EndConversation()
{
    Super.EndConversation();
    realLastConEndTime = LastConEndTime;
    LastConEndTime += 59.0;
}

function Frob(actor Frobber, Inventory frobWith)
{
    LastConEndTime = realLastConEndTime;
    Super.Frob(Frobber, frobWith);
}
