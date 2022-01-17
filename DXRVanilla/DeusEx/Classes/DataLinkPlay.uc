class DataLinkPlay injects DataLinkPlay;

function bool PushDataLink( Conversation queueCon )
{
    local bool bRet;
    local ConEvent currEvent;
    local ConEventSpeech event;

    // get rid of the speech for our next event
    currEvent = currentEvent;
    if(currentEvent != None)
        event = ConEventSpeech(currEvent.nextEvent);
    
    if (
        event != None
        && event.conSpeech != None
        && event.conSpeech.soundID != -1
    ) {
        event.conSpeech.soundID = -1;
    }

    // queue up the incoming message
    bRet = Super.PushDataLink(queueCon);

    // abort our current event and play the next event after we removed the speech from it
    if(currEvent != None)
        PlayNextEvent();
    return bRet;
}

defaultproperties
{
    blinkRate=0.500000
    startDelay=0.500000
    endDelay=0.500000
    perCharDelay=0.020000
}
