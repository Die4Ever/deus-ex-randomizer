class DXRAllianceTrigger injects #var(prefix)AllianceTrigger;

var() bool bPlayerOnly;

function Trigger(Actor Other, Pawn Instigator)
{
    if (!bPlayerOnly || #var(PlayerPawn)(Instigator) != None) {
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

            if (Alliance!=''){
                //In the vanilla game, MOST alliance triggers set an alliance,
                //but there are a few that leave it blank, which unintentionally
                //clears the alliance of the targeted pawn.  This changes the
                //behaviour of who they will listen to to determine who might
                //be a possible enemy.  Most places, this doesn't really matter,
                //but if there are multiple alliances in-fighting, or multiple
                //blank alliances, they could get themselves confused.  See
                //commit 471ccad for an example of where a blank alliance
                //caused problems.
                P.SetAlliance(Alliance);
            }
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
