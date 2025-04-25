class DXRMission03 injects Mission03;

function FirstFrame()
{
    local ScriptedPawn P;
    local bool trashEm;

    trashEm=False;

    if (localURL == "03_NYC_AIRFIELDHELIBASE" || localURL == "03_NYC_AIRFIELD")
    {
        if (flags.GetBool('MeetLebedev_Played') ||
            flags.GetBool('JuanLebedev_Dead'))
        {
            trashEm = True;
        }
    }

    if (trashEm)
    {
        foreach AllActors(class'ScriptedPawn', P)
        {
            if (P.GetAllianceType('player')!=ALLIANCE_Hostile) continue; //Only destroy enemies
            if (InStr(P.Tag,"_clone")!=-1) P.Destroy();
        }
    }
    Super.FirstFrame();
}
