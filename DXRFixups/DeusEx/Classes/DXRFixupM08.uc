class DXRFixupM08 extends DXRFixup;

function AnyEntryMapFixes()
{
    local StantonDowd s;

    Super.AnyEntryMapFixes();

    switch(dxr.localURL) {
    case "08_NYC_STREET":
        SetTimer(1.0, True);
        foreach AllActors(class'StantonDowd', s) {
            RemoveReactions(s);
        }
        Player().StartDataLinkTransmission("DL_Entry");
        break;

#ifdef vanillamaps
    case "08_NYC_SMUG":
        FixConversationGiveItem(GetConversation('M08MeetFordSchick'), "AugmentationUpgrade", None, class'AugmentationUpgradeCannister');
        break;
#endif
    }
}

function TimerMapFixes()
{
    local BlackHelicopter chopper;

    switch(dxr.localURL)
    {
        case "08_NYC_STREET":
        if (#defined(vanillamaps) && dxr.flagbase.GetBool('StantonDowd_Played') )
        {
            foreach AllActors(class'BlackHelicopter', chopper, 'CopterExit')
                chopper.EnterWorld();
            dxr.flagbase.SetBool('MS_Helicopter_Unhidden', True,, 9);
        }
        UpdateGoalWithRandoInfo('FindHarleyFilben');
        break;
    }
}
