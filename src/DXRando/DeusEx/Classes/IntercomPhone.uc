class IntercomPhone extends #var(prefix)Phone;

var string message;
var int soundId;

function Tick(float deltaTime)
{
    Super(#var(prefix)ElectronicDevices).Tick(deltaTime); //Skip the Phone Tick so it doesn't ring
}

function Timer()
{
    bUsing = False;
    if (soundId!=0){
        StopSound(soundId);
        soundId=0;
    }
}

function Frob(actor Frobber, Inventory frobWith)
{
    local float rnd;
    local #var(prefix)Pawn p;

    Super(#var(prefix)ElectronicDevices).Frob(Frobber, frobWith);

    if (bUsing || InConversationState())
        return;

    SetTimer(3.0, False);
    bUsing = True;

    soundId=PlaySound(sound'PhoneBusy', SLOT_Misc,,, 256);

    p = #var(prefix)Pawn(Frobber);
    if(p!=None){
        p.ClientMessage(message);
    }
}

function bool InConversationState()
{
    return ((GetStateName() == 'Conversation') || (GetStateName() == 'FirstPersonConversation'));
}
