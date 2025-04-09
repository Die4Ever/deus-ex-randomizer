class DXRConPlay injects ConPlay;

var float pitchAdjust;

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
