class MissionScript injects MissionScript transient abstract;

var DXRando dxr;

// have to copy this whole function just to let DXRBacktracking handle the DeleteExpiredFlags
// also use dxr.localURL instead of dxInfo.mapName because of DXRMapVariants
function InitStateMachine()
{
    local DeusExLevelInfo info;

    Player = DeusExPlayer(GetPlayerPawn());

    foreach AllActors(class'DeusExLevelInfo', info)
        dxInfo = info;

    if (Player != None)
    {
        flags = Player.FlagBase;

        // Get the mission number by extracting it from the
        // DeusExLevelInfo and then delete any expired flags.
        //
        // Also set the default mission expiration so flags
        // expire in the next mission unless explicitly set
        // differently when the flag is created.

        if (flags != None)
        {
            // Don't delete expired flags if we just loaded
            // a savegame
            if (flags.GetBool('PlayerTraveling'))
                class'DXRBacktracking'.static.DeleteExpiredFlags(flags, dxInfo.MissionNumber);

            flags.SetDefaultExpiration(dxInfo.MissionNumber + 1);

            localURL = dxr.localURL;

            log("**** InitStateMachine() -"@player@"started mission state machine for"@localURL);
        }
        else
        {
            log("**** InitStateMachine() - flagBase not set - mission state machine NOT initialized!");
        }
    }
    else
    {
        log("**** InitStateMachine() - player not set - mission state machine NOT initialized!");
    }
}

function FirstFrame()
{
    local string mapName;

    // because of DXRMapVariants
    mapName = dxInfo.mapName;
    dxInfo.mapName = class'DXRMapVariants'.static.CleanupMapName(mapName);

    Super.FirstFrame();
    dxInfo.mapName = mapName;
}

function Timer()
{
    // ensure DXRFlags can load flags before we start
    if( dxr == None ) foreach AllActors(class'DXRando', dxr) break;
    if( dxr == None ) return;
    if( dxr.flagbase == None ) return;

    Super.Timer();
}
