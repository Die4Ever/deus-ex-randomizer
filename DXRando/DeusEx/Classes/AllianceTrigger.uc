#ifdef injections
class DXRAllianceTrigger injects AllianceTrigger;
#else
class DXRAllianceTrigger extends #var prefix AllianceTrigger;
#endif

var() bool bPlayerOnly;

function Trigger(Actor Other, Pawn Instigator)
{
    if (!bPlayerOnly || #var PlayerPawn (Instigator) != None) {
        Super.Trigger(Other,Instigator);
    }
}

#ifdef hx
function SetAlliances()
{
    _SetAlliances();
}

function bool _SetAlliances()
#else
function bool SetAlliances()
#endif
{
    local ScriptedPawn P;
    local int i;
    local name newtag;

    // find the target NPC to set alliances
    if (Event != '')
    {
        newtag = StringToName(Event $ "_clone");
        foreach AllActors (class'ScriptedPawn', P)
        {
            if( P.Tag != Event && P.Tag != newtag ) continue;

            P.SetAlliance(Alliance);
            for (i=0; i<ArrayCount(Alliances); i++)
                if (Alliances[i].AllianceName != '')
                    P.ChangeAlly(Alliances[i].AllianceName, Alliances[i].AllianceLevel, Alliances[i].bPermanent);
        }
    }
    return true;
}

#ifndef hx
function Name StringToName(string s)
{
    local DeusExPlayer player;
    player = DeusExPlayer(GetPlayerPawn());
    return player.rootWindow.StringToName(s);
}
#endif
