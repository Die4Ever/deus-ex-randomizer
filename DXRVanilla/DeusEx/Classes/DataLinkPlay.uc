class DataLinkPlay injects DataLinkPlay;

var transient float speechFastEndTime;
var transient bool restarting;
var DataLinkTrigger dataLinkTriggerQueue[16];
var transient float pitchAdjust;

function bool bIsFastMode()
{
    local DXRando dxr;

    if(!HaveQueued()) return false;
    if(Human(player).bZeroRando) return false;
    dxr = Human(player).GetDXR();
    if(dxr != None && dxr.dxInfo.missionNumber == 0) {
        return false;
    }
    return true;
}

function bool PushDataLink( Conversation queueCon )
{
    // queue up the incoming message
    if(Super.PushDataLink(queueCon) == false)
        return false;

    // make our timer shorter
    if(bIsFastMode() && speechFastEndTime!=0 && currentEvent != None)
        SetTimer(FClamp(speechFastEndTime - Level.Timeseconds, 0.1, 5), false);

    return true;
}

function PlaySpeech( int soundID )
{
    local Sound speech;

    pitchAdjust = class'DXRMemes'.static.GetVoicePitch(Human(player).dxr);
    perCharDelay = default.perCharDelay / pitchAdjust;

    speechFastEndTime = Level.Timeseconds + lastSpeechTextLength * perCharDelay;

    speech = con.GetSpeechAudio(soundID);

    if (speech != None)
        playingSoundID = player.PlaySound(speech, SLOT_Talk,,,,pitchAdjust);
}

function bool HaveQueued()
{
    return dataLinkQueue[0] != None;
}

function FastForward()
{
    bSilent = True;

    // Make sure no sound playing
    player.StopSound(playingSoundId);

    if ((!bEndTransmission) && (bStartTransmission))
    {
        bStartTransmission = False;
        SetTimer(0.0, False);
    }
    else if(GetStateName() == 'WaitForSpeech') {
        PlayNextEvent();
    }

    while(currentEvent != None) {
        SetupEventFunc();
    }

    rootWindow.hud.DestroyInfoLinkWindow();
    dataLink = None;

    if ( FireNextDataLink() == False )
    {
        player.dataLinkPlay = None;
        Destroy();
    }
    else
    {
        FastForward();
    }
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
    if(restarting || bSilent) {
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
    pitchAdjust = class'DXRMemes'.static.GetVoicePitch(Human(player).dxr);
    perCharDelay = default.perCharDelay / pitchAdjust;
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

        if(!bIsFastMode()) {
            // Add two seconds to the sound since there seems to be a slight lag
            SetTimer( con.GetSpeechLength(ConEventSpeech(currentEvent).conSpeech.soundID) / pitchAdjust, False );
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

// fix for issue with getting overwritten even when failing to play, then calling datalinkTrigger.DatalinkFinished() with the wrong datalinkTrigger
// https://www.youtube.com/clip/UgkxHMQ1A0QuuXX9TURsxzDU5BF632aDr1cm
// https://discord.com/channels/823629359931195394/823629734457114654/1145385071721840660
function SetTrigger(DataLinkTrigger newDatalinkTrigger)
{
    local int i;

    for(i=0; i<ArrayCount(dataLinkTriggerQueue); i++) {
        if(dataLinkTriggerQueue[i] == None) {
            dataLinkTriggerQueue[i] = newDatalinkTrigger;
            break;
        }
        if(dataLinkTriggerQueue[i] == newDatalinkTrigger) {
            break;
        }
    }
}

function NotifyDatalinkTrigger()
{
    local int i;

    for(i=0; i<ArrayCount(dataLinkTriggerQueue); i++) {
        if(dataLinkTriggerQueue[i] == None) {
            continue;
        }
        if(dataLinkTriggerQueue[i].datalinkTag == startCon.conName) {
            dataLinkTriggerQueue[i].DatalinkFinished();
            dataLinkTriggerQueue[i] = None;
        }
    }
}


// copied from state PlayEvent, because FastForward needs this to happen immediately
function SetupEventFunc()
{
    local EEventAction nextAction;
    local String nextLabel;

    if ( currentEvent == None ) {
        TerminateConversation();
        return;
    }

    switch( currentEvent.EventType )
    {
        // Unsupported events
        case ET_MoveCamera:
        case ET_Choice:
        case ET_Animation:
        case ET_Trade:
            break;

        case ET_Speech:
            nextAction = SetupEventSpeech( ConEventSpeech(currentEvent), nextLabel );
            break;

        case ET_SetFlag:
            nextAction = SetupEventSetFlag( ConEventSetFlag(currentEvent), nextLabel );
            break;

        case ET_CheckFlag:
            nextAction = SetupEventCheckFlag( ConEventCheckFlag(currentEvent), nextLabel );
            break;

        case ET_CheckObject:
            nextAction = SetupEventCheckObject( ConEventCheckObject(currentEvent), nextLabel );
            break;

        case ET_Jump:
            nextAction = SetupEventJump( ConEventJump(currentEvent), nextLabel );
            break;

        case ET_Random:
            nextAction = SetupEventRandomLabel( ConEventRandomLabel(currentEvent), nextLabel );
            break;

        case ET_Trigger:
            nextAction = SetupEventTrigger( ConEventTrigger(currentEvent), nextLabel );
            break;

        case ET_AddGoal:
            nextAction = SetupEventAddGoal( ConEventAddGoal(currentEvent), nextLabel );
            break;

        case ET_AddNote:
            nextAction = SetupEventAddNote( ConEventAddNote(currentEvent), nextLabel );
            break;

        case ET_AddSkillPoints:
            nextAction = SetupEventAddSkillPoints( ConEventAddSkillPoints(currentEvent), nextLabel );
            break;

        case ET_AddCredits:
            nextAction = SetupEventAddCredits( ConEventAddCredits(currentEvent), nextLabel );
            break;

        case ET_CheckPersona:
            nextAction = SetupEventCheckPersona( ConEventCheckPersona(currentEvent), nextLabel );
            break;

        case ET_TransferObject:
            nextAction = SetupEventTransferObject( ConEventTransferObject(currentEvent), nextLabel );
            break;

        case ET_End:
            nextAction = SetupEventEnd( ConEventEnd(currentEvent), nextLabel );
            break;
    }

    // Based on the result of the setup, we either need to jump to another event
    // or wait for some input from the user.

    ProcessAction( nextAction, nextLabel );
}


defaultproperties
{
    blinkRate=0.3
    startDelay=0.3
    endDelay=0.3
    perCharDelay=0.02
}
