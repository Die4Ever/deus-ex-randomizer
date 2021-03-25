class MissionEndgame injects MissionEndgame;

function PostPostBeginPlay()
{
    savedSoundVolume = SoundVolume;
    Super.PostPostBeginPlay();
}

// ----------------------------------------------------------------------
// InitStateMachine()
// ----------------------------------------------------------------------

function InitStateMachine()
{
    Super(MissionScript).InitStateMachine();

    // Destroy all flags!
    //if (flags != None)
    //    flags.DeleteAllFlags();

    // Set the PlayerTraveling flag (always want it set for 
    // the intro and endgames)
    flags.SetBool('PlayerTraveling', True, True, 0);
}

// ----------------------------------------------------------------------
// FirstFrame()
// 
// Stuff to check at first frame
// ----------------------------------------------------------------------

function FirstFrame()
{
    Super(MissionScript).FirstFrame();

    endgameTimer = 0.0;

    if (Player != None)
    {
        // Make sure all the flags are deleted.
        //DeusExRootWindow(Player.rootWindow).ResetFlags();

        // Start the conversation
        if (localURL == "ENDGAME1")
            Player.StartConversationByName('Endgame1', Player, False, True);
        else if (localURL == "ENDGAME2")
            Player.StartConversationByName('Endgame2', Player, False, True);
        else if (localURL == "ENDGAME3")
            Player.StartConversationByName('Endgame3', Player, False, True);

        // turn down the sound so we can hear the speech
        savedSoundVolume = SoundVolume;
        SoundVolume = 32;
        Player.SetInstantSoundVolume(SoundVolume);
    }
}
