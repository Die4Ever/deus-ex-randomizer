class DataLinkPlay injects DataLinkPlay;

var float speechFastEndTime;

function bool PushDataLink( Conversation queueCon )
{
    // queue up the incoming message
    if(Super.PushDataLink(queueCon) == false)
        return false;

    // make our timer shorter
    if(speechFastEndTime > Level.Timeseconds + 0.1 && currentEvent != None)
        SetTimer(speechFastEndTime - Level.Timeseconds, false);
    
    return true;
}

function PlaySpeech( int soundID )
{
    speechFastEndTime = Level.Timeseconds + lastSpeechTextLength * perCharDelay;
    Super.PlaySpeech(soundID);
}

function bool HaveQueued()
{
    return dataLinkQueue[0] != None;
}

// ----------------------------------------------------------------------
// state WaitForSpeech
//
// Waiting for a sound to finish playing
// ----------------------------------------------------------------------

state WaitForSpeech
{
    // We get here when the timer we set when playing the sound
    // has finished.  We want to play the next event.
    function Timer()
    {
        GotoState( 'WaitForSpeech', 'SpeechFinished' );
    }

SpeechFinished:

    // Sleep for a second before continuing
    Sleep(0.5);

    // Fire the next event
    PlayNextEvent();
    Stop;

Idle:
    Sleep(0.5);
    Goto('Idle');

Begin:
    // Play the sound, set the timer and go to sleep until the sound
    // has finished playing.
    
    // First Stop any sound that was playing
    StopSpeech();

    // Check to see if there's speech to play.  If so, play it and set a 
    // timer that should complete after the speech finishes.  Otherwise 
    // we'll just display the datalink message for a set amount of time
    // and continue.

    if (ConEventSpeech(currentEvent).conSpeech.soundID != -1 )
    {
        PlaySpeech( ConEventSpeech(currentEvent).conSpeech.soundID ); 

        if(HaveQueued() == false) {
            // Add two seconds to the sound since there seems to be a slight lag
            SetTimer( con.GetSpeechLength(ConEventSpeech(currentEvent).conSpeech.soundID), False );
        } else {
            // if we have queued items, use the fast timer just for showing text
            SetTimer( lastSpeechTextLength * perCharDelay, False );
        }
    }
    else
    {
        SetTimer( lastSpeechTextLength * perCharDelay, False );
    }

    Goto('Idle');
}


defaultproperties
{
    blinkRate=0.500000
    startDelay=0.500000
    endDelay=0.500000
    perCharDelay=0.020000
}
