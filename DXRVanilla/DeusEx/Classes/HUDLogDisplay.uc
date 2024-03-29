class DXRHUDLogDisplay injects HUDLogDisplay;
// make the error sounds from DXRInfo.err() more obvious

event VisibilityChanged(bool bNewVisibility)
{
    Super(HUDSharedBorderWindow).VisibilityChanged( bNewVisibility );

    bTickEnabled = bNewVisibility;

    if ( winLog != None )
        winLog.PauseLog( !bNewVisibility );

    // If we just became visible and we have a log sound to play,
    // then do it now

    if ( bNewVisibility && ( logSoundToPlay != None ))
    {
        if(logSoundToPlay == Sound'DeusExSounds.Generic.Buzz1')
            PlaySound(logSoundToPlay, 2);
        else
            PlaySound(logSoundToPlay, 0.75);
        logSoundToPlay = None;
    }
}

function PlayLogSound(Sound newLogSound)
{
    // If the log is visible, play this sound right now.
    // Otherwise wait until we become visible

    if ( IsVisible() )
    {
        if(newLogSound == Sound'DeusExSounds.Generic.Buzz1')
            PlaySound(newLogSound, 2);
        else
            PlaySound(newLogSound, 0.75);
        logSoundToPlay = None;
    }
    else if(logSoundToPlay != Sound'DeusExSounds.Generic.Buzz1')
    {
        logSoundToPlay = newLogSound;
    }
}
