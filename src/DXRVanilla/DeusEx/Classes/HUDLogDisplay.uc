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

// ----------------------------------------------------------------------
// Tick()
//
// Used to display the log window for 'x' number of seconds before
// hiding it again.
// ----------------------------------------------------------------------

event Tick(float deltaSeconds)
{
    local bool bNoDataLink, bNoConv;
    local DeusExRootWindow root;

    // If a DataLink or Conversation is being played, then don't count down,
    // so we don't miss any log messages the player might receive.

    // DXRando: allow counting down during datalink if your window is wide enough
    root = DeusExRootWindow(GetRootWindow());
    bNoDataLink = player.dataLinkPlay == None || root.hud.width >= root.hud.infolink_and_logs_min_width;
    // if there is a conversation, first-person conversations don't count (barks) because our window still shows
    bNoConv = player.conPlay == None || (player.conPlay != None && player.conPlay.GetDisplayMode() == DM_FirstPerson);
    if (bNoDataLink && bNoConv)
    {
        if (( lastLogMsg > 0.0 ) && ( lastLogMsg + deltaSeconds > displayTime ))
        {
            bTickEnabled     = False;
            bMessagesWaiting = False;
            Hide();
            winLog.PauseLog(False);
            AskParentForReconfigure();
        }
        lastLogMsg = lastLogMsg + deltaSeconds;
    }
}

function AddLog(coerce String newLog, Color linecol)
{
    local DeusExRootWindow root;
    local PersonaScreenBaseWindow winPersona;

    if ( newLog != "" )
    {
        root = DeusExRootWindow(GetRootWindow());

        // If a PersonaBaseWindow is visible, send the log message
        // that way as well.

        winPersona = PersonaScreenBaseWindow(root.GetTopWindow());
        if (winPersona != None)
            winPersona.AddLog(newLog);

        // If the Hud is not visible, then pause the log
        // until we become visible again
        //
        // Don't show the log if a DataLink is playing
        // DXRando: check window width too to show while DataLink is player
        if (GetParent().IsVisible() && (root.hud.infolink == None || root.hud.width >= root.hud.infolink_and_logs_min_width))
        {
            Show();
        }
        else
        {
            bMessagesWaiting = True;
            winLog.PauseLog( True );
        }

        bTickEnabled = TRUE;
        winLog.AddLog(newLog, linecol);
        lastLogMsg = 0.0;
        AskParentForReconfigure();
    }
}

defaultproperties
{
    fontLog=Font'DXRFontMenuSmall_DS'
}
