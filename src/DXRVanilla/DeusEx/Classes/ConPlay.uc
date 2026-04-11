class DXRConPlay injects ConPlay;

var float pitchAdjust;
var bool fastForwarding;
var bool savedContinueSpeech;
var bool savedNoPlayedFlag;

//Copied from ConPlay, but added pitchAdjust
function PlaySpeech( int soundID, Actor speaker )
{
    local Sound speech;

    pitchAdjust=class'DXRMemes'.static.GetVoicePitch(Human(player).dxr);
    perCharDelay = default.perCharDelay / pitchAdjust;
    minimumTextPause = default.minimumTextPause / pitchAdjust;

    speech = con.GetSpeechAudio(soundID);

    // Keep a pointer to the current speaking pawn so we can stop
    // the speech animation when we're finished.

    if (speech != None)
    {
        // If this is an intro/endgame, force speech to play through
        // the player so we can *hear* it.
        if (bForcePlay)
        {
            // Check how close the player is to this actor.  If the player is
            // close enough to the speaker, play through the speaker.
            if ((speaker == None) || (VSize(player.Location - speaker.Location) > 400))
            {
                playingSoundID = player.PlaySound(speech, SLOT_Talk,,,65536.0,pitchAdjust);
            }
            else
            {
                playingSoundID = speaker.PlaySound(speech, SLOT_Talk,,,65536.0,pitchAdjust);
            }
        }
        else
        {
            // If this is a forced conversation (bCannotBeInterrupted = True)
            // then set the radius higher.  This is a hack.  Yes, a hack,
            // in some situations where the PC is far from one or more speaking
            // NPCs but needs to be able to overhear them.  Also, want to make
            // this reasonably loud for letterbox convos

            if ((con.bCannotBeInterrupted) || (!con.bFirstPerson))
                playingSoundID = speaker.PlaySound(speech, SLOT_Talk,,,65536.0,pitchAdjust);
            else
                playingSoundID = speaker.PlaySound(speech, SLOT_Talk,,,512.0 + initialRadius,pitchAdjust);
        }
    }

    StartSpeakingAnimation();
}


state WaitForSpeech
{
    // We get here when the timer we set when playing the sound
    // has finished.  We want to play the next event.
    function Timer()
    {
        GotoState( 'WaitForSpeech', 'SpeechFinished' );
    }

SpeechFinished:
    // Restrict input
    if (conWinThird != None)
        conWinThird.RestrictInput(True);

    StopSpeakingAnimation();

    // Sleep for a second before continuing
    Sleep(0.5);

    // Fire the next event
    PlayNextEvent();
    Stop;

Idle:
    // Allow input
    if (conWinThird != None)
        conWinThird.RestrictInput(False);

    Sleep(0.5);
    Goto('Idle');

Begin:

    pitchAdjust=class'DXRMemes'.static.GetVoicePitch(Human(player).dxr);
    perCharDelay = default.perCharDelay / pitchAdjust;
    minimumTextPause = default.minimumTextPause / pitchAdjust;

    // If this is a first person conversation and A) we don't have speech
    // or B) we're in "Subtitles Only" mode, then set a timer based on
    // the length of speech.

    if ( ConEventSpeech(currentEvent).conSpeech.soundID == -1 )
    {
        SetTimer( FMax(lastSpeechTextLength * perCharDelay / pitchAdjust, minimumTextPause), False );
    }
    else
    {
        // Play the sound, set the timer and go to sleep until the sound
        // has finished playing.

        // First Stop any sound that was playing
        PlaySpeech( ConEventSpeech(currentEvent).conSpeech.soundID, ConEventSpeech(currentEvent).Speaker );

        // Add two seconds to the sound since there seems to be a slight lag
        SetTimer( con.GetSpeechLength(ConEventSpeech(currentEvent).conSpeech.soundID)/pitchAdjust, False );
        log ("Original timer length: "$con.GetSpeechLength(ConEventSpeech(currentEvent).conSpeech.soundID)$"  pitch adjust:  "$pitchAdjust$"   after adjust length: "$con.GetSpeechLength(ConEventSpeech(currentEvent).conSpeech.soundID)/pitchAdjust);
    }

    Goto('Idle');
}

//Copied from ConPlay::SetupEvent, but stripped out event types that we don't want to fast forward through
function SetupEventFastForward()
{
    local EEventAction nextAction;
    local String nextLabel;

    //player.ClientMessage("Fast Forwarding through Event Type "$currentEvent.EventType);

    switch( currentEvent.EventType )
    {
        case ET_SetFlag:
            nextAction = SetupEventSetFlag( ConEventSetFlag(currentEvent), nextLabel );
            break;

        case ET_CheckFlag:
            nextAction = SetupEventCheckFlag( ConEventCheckFlag(currentEvent), nextLabel );
            break;

        case ET_CheckObject:
            nextAction = SetupEventCheckObject( ConEventCheckObject(currentEvent), nextLabel );
            break;

        case ET_TransferObject:
            nextAction = SetupEventTransferObject( ConEventTransferObject(currentEvent), nextLabel );
            break;

        case ET_MoveCamera:
            // Not allowed in passive mode
            if ( playMode == PM_Active )
            {
                nextAction = SetupEventMoveCamera( ConEventMoveCamera(currentEvent), nextLabel );
            }
            break;

        case ET_Animation:
            nextAction = SetupEventAnimation( ConEventAnimation(currentEvent), nextLabel );
            break;

        case ET_Jump:
            nextAction = SetupEventJump( ConEventJump(currentEvent), nextLabel );
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

        case ET_Trade: //Moved (This isn't real though???)
        case ET_Random: //Moved
        case ET_Choice: //Moved
        case ET_Speech: //Moved (We don't play any more speech)
        case ET_End:
            //player.ClientMessage("Fast Forward ending conversation");
            nextAction = SetupEventEnd( ConEventEnd(currentEvent), nextLabel );
            break;
    }

    // Based on the result of the setup, we either need to jump to another event
    // or wait for some input from the user.

    ProcessActionFastForward( nextAction, nextLabel ); //DXRando
}

function ProcessActionFastForward( EEventAction nextAction, string nextLabel )
{
    // Don't do squat if the currentEvent is NONE
    if (currentEvent == None)
        return;

    switch( nextAction )
    {
        case EA_NextEvent:
        case EA_WaitForSpeech:
        case EA_WaitForText:
        case EA_PlayAnim:
        case EA_ConTurnActors:
            // Proceed to the next event.
            lastEvent = currentEvent;
            currentEvent = currentEvent.nextEvent;
            SetupEventFastForward(); //DXRando
            break;

        case EA_JumpToLabel:
            // Use the label passed back and jump to it
            lastEvent = currentEvent;
            currentEvent = con.GetEventFromLabel( nextLabel );
            if ( currentEvent == None )
            {
                Log("ConPlay::ProcessActionFastForward() - EA_JumpToLabel ----------------------------");
                Log("  WARNING!  Label " $ nextLabel $ " NOT FOUND in Conversation " $ con.conName);
                log("  Conversation Terminated for real.");
            }
            SetupEventFastForward(); //DXRando
            break;

        case EA_JumpToConversation:
            lastEvent = currentEvent;
            JumpToConversationFastForward( ConEventJump(currentEvent).jumpCon, nextLabel ); //DXRando
            break;

        case EA_WaitForInput: //DXRando
        case EA_End:
            TerminateConversation();
            break;
    }
}

function JumpToConversationFastForward( Conversation jumpCon, String startLabel )
{
    assert( jumpCon != None );

    // If this is a new conversation, assign it to our "Con" variable
    // and set the con.conName $ "_Played" flag to True.
    if (jumpCon != con)
    {
        SetPlayedFlag();

        // Some cleanup for the existing conversation
        con.ClearBindEvents();
        con.radiusDistance = saveRadiusDistance;

        // Assign the new conversation and bind the events
        con = jumpCon;
        con.BindEvents(ConActorsBound, startActor);
    }

    // Get the event to start at, or the beginning if one wasn't
    // passed in.  However, if a label is passed in *and* it's not
    // found, then abort the conversation!!

    currentEvent = con.GetEventFromLabel( startLabel );

    if (( currentEvent == None ) && ( startLabel != "" ))
    {
        Log("ConPlay::JumpToConversationFastForward() --------------------------------------");
        Log("  WARNING!  Label [" $ startLabel $ "] NOT FOUND in Conversation [" $ jumpCon.conName $ "]");
        log("  Conversation Terminated for real.");
        TerminateConversation();
        return;
    }

    if ( currentEvent == None )
        currentEvent = con.eventList;

    // Start the conversation!
    SetupEventFastForward(); //DXRando
}


//Make sure the fast forward flag is cleared when starting a new conversation
function Bool StartConversation(DeusExPlayer newPlayer, optional Actor newInvokeActor, optional bool bForcePlay)
{
    fastForwarding = false;
    return Super.StartConversation(newPlayer, newInvokeActor, bForcePlay);
}

function FastForward()
{
    if (fastForwarding) return;

    //player.ClientMessage("Fast forwarding conversation "$con.conName);

    fastForwarding=true;

    //If interrupted mid-speech event, skip to the next event before starting the fast forward
    if (currentEvent.EventType==ET_Speech){
        lastEvent = currentEvent;
        currentEvent = currentEvent.nextEvent;
    }

    SetupEventFastForward();
}

//Fast forward if appropriate, otherwise terminate as normal
function TerminateConversation(optional bool bContinueSpeech, optional bool bNoPlayedFlag)
{
    if (!fastForwarding){
        if (displayMode == DM_FirstPerson && currentEvent!=None && currentEvent.EventType!=ET_End){
            //Save these to reuse once the fast forward is finished
            savedContinueSpeech = bContinueSpeech;
            savedNoPlayedFlag = bNoPlayedFlag;

            FastForward();

            return;
        }
    }

    if (fastForwarding){
        //Restore the settings from when the conversation was first being terminated
        bContinueSpeech = savedContinueSpeech;
        bNoPlayedFlag = savedNoPlayedFlag;
    }

    Super.TerminateConversation(bContinueSpeech,bNoPlayedFlag);
}

defaultproperties
{
     ConversationSpeechFonts(0)=Font'DXRFontConversation'
     ConversationSpeechFonts(1)=Font'DXRFontConversationLarge'
     ConversationNameFonts(0)=Font'DXRFontConversationBold'
     ConversationNameFonts(1)=Font'DXRFontConversationLargeBold'
}
