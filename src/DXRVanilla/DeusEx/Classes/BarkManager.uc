class DXRBarkManager injects BarkManager;

//Copied from regular BarkManager, added pitchAdjust
function bool StartBark(DeusExRootWindow newRoot, ScriptedPawn newBarkPawn, EBarkModes newBarkMode)
{
    local Name         conName;
    local Conversation con;
    local int          barkIndex;
    local Float        barkDuration;
    local bool         bBarkStarted;
    local ConPlayBark  conPlayBark;
    local String       conSpeechString;
    local ConSpeech    conSpeech;
    local Sound        speechAudio;
    local bool         bHaveSpeechAudio;
    local int          playingSoundID;
    local float        pitchAdjust;

    pitchAdjust=class'DXRMemes'.static.GetVoicePitch(Human(owner).dxr);
    minimumTextPause = Default.minimumTextPause / pitchAdjust;

    bBarkStarted = False;

    // Store away the root window
    rootWindow = newRoot;

    // Don't even go any further if the actor is too far away
    // from the player
    if (!CheckRadius(newBarkPawn))
        return False;

    // Now check the height difference
    if (!CheckHeightDifference(newBarkPawn))
        return False;

    // First attempt to find this conversation
    conName = BuildBarkName(newBarkPawn, newBarkMode);

    // Okay, we have the name of the bark, now attempt to find a
    // conversation based on this name.
    con = ConListItem(newBarkPawn.conListItems).FindConversationByName(conName);

    if (con != None)
    {
        barkIndex = GetAvailableCurrentBarkSlot(newBarkPawn, newBarkMode);

        // Abort if we don't get a valid barkIndex back
        if (barkIndex == -1)
            return False;

        // Make sure that another NPC isn't already playing this
        // particular bark.
        if (IsBarkPlaying(conName))
            return False;

        // Now check to see if the same kind of bark has already been
        // played by this NPC within a certain range of time.
        if (HasBarkTypePlayedRecently(newBarkPawn, newBarkMode))
            return False;

        // Summon a 'ConPlayBark' object, which will process
        // the conversation and play the bark.
        // Found an active conversation, so start it
        conPlayBark = Spawn(class'ConPlayBark');
        conPlayBark.SetConversation(con);

        conSpeech = conPlayBark.GetBarkSpeech();

        bHaveSpeechAudio = False;

        // Nuke conPlayBark
        conPlayBark.Destroy();

        // Play the audio (if we have audio)
        if ((conSpeech != None) && (conSpeech.soundID != -1))
        {
            speechAudio = con.GetSpeechAudio(conSpeech.soundID);

            if (speechAudio != None)
            {
                bHaveSpeechAudio = True;
                playingSoundID = newBarkPawn.PlaySound(speechAudio, SLOT_Talk,,,1024.0,pitchAdjust);
                barkDuration = con.GetSpeechLength(conSpeech.soundID) / pitchAdjust;
            }
        }

        // If we don't have any audio, then calculate the timer based on the
        // length of the speech text.

        if ((conSpeech != None) && (!bHaveSpeechAudio))
            barkDuration = FMax(Len(conSpeech.speech) * perCharDelay / pitchAdjust, minimumTextPause);

        // Show the speech if Subtitles are on
        if ((DeusExPlayer(owner) != None) && (DeusExPlayer(owner).bSubtitles) && (conSpeech != None) && (conSpeech.speech != ""))
        {
            rootWindow.hud.barkDisplay.AddBark(conSpeech.speech, barkDuration, newBarkPawn);
        }

        // Keep track fo the bark
        SetBarkInfo(barkIndex, conName, newBarkPawn, newBarkMode, barkDuration, playingSoundID);

        bBarkStarted = True;
    }

    return bBarkStarted;
}
