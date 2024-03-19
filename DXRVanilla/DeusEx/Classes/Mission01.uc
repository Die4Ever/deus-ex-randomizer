class DXRMission01 injects Mission01;

function Timer()
{
    local ScriptedPawn P;

    if (!flags.GetBool('MS_MissionComplete'))
    {
        if (flags.GetBool('StatueMissionComplete'))
        {
            foreach AllActors(class'ScriptedPawn', P)
            {
                if (P.GetAllianceType('player')!=ALLIANCE_Hostile) continue; //Only destroy enemies
                if (#var(prefix)Terrorist(P)!=None) continue; //Skip these and let the original script handle them
                if (InStr(P.Tag,"_clone")!=-1) P.Destroy();
            }
            //The original mission script will mark MS_MissionComplete
        }
    }
    Super.Timer();
}
