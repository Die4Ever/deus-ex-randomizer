class DataLinkPlay injects DataLinkPlay;

var float speechFastEndTime;
var bool restarting;

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

/////

function Bool StartConversation(DeusExPlayer newPlayer, optional Actor newInvokeActor, optional bool bForcePlay)
{
    local Actor tempActor;

    if ( Super(ConPlayBase).StartConversation(newPlayer, newInvokeActor, bForcePlay) == False )
        return False;

    // Create the DataLink display if necessary.  If it already exists,
    // then we're presently in a DataLink and need to queue this one up
    // for play after the current DataLink is finished.
    //
    // Don't play the DataLink if
    //
    // 1.  A First-person conversation is currently playing
    // 2.  Player is rooting around inside a computer
    //
    // In these cases we'll just queue it up instead

    if ( ( dataLink == None ) &&
        ((player.conPlay == None) && (NetworkTerminal(rootWindow.GetTopWindow()) == None)))
    {
        lastSpeechTextLength = 0;
        bEndTransmission = False;
        eventTimer = 0;

        datalink = rootWindow.hud.CreateInfoLinkWindow();

        if ( dataLinkQueue[0] != None )
            dataLink.MessageQueued(True);
    }
    else
    {
        return True;
    }

    // Grab the first event!
    currentEvent = con.eventList;

    // Create the history object.  Passing in True means
    // this is an InfoLink conversation.
    SetupHistory(GetDisplayName(con.GetFirstSpeakerDisplayName()), True);

    // Play a sound and wait a few seconds before starting
    datalink.ShowTextCursor(False);
    if(restarting) {
        bStartTransmission = True;
        restarting = false;
        SetTimer(0.05, True);
    } else {
        player.PlaySound(startSound, SLOT_None);
        bStartTransmission = True;
        SetTimer(blinkRate, True);
    }
    return True;
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
    blinkRate=0.3
    startDelay=0.3
    endDelay=0.3
    perCharDelay=0.015
}
