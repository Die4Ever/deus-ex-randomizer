class DXRMission11 injects Mission11;

function Timer()
{
    local DXRMapVariants mapvariants;
    local string map;

    if (localURL == "11_PARIS_UNDERGROUND" && flags != None)
    {
        // knock out the player and teleport him after this convo
        if (flags.GetBool('MeetTobyAtanwe_Played') &&
            flags.GetBool('MS_LetTobyTakeYou_Rando') &&
            !flags.GetBool('MS_PlayerTeleported'))
        {
            flags.SetBool('MS_PlayerTeleported', True,, 12);
            map = "11_PARIS_EVERETT";
            foreach AllActors(class'DXRMapVariants', mapvariants) {
                map = mapvariants.VaryMap(map);
                break;
            }
            Level.Game.SendPlayer(Player, map);
        }

        //Reset the conversation flag if you haven't actually asked him to take you
        //Pretty sure MeetTobyAtanwe_Played will always be set if FemJCMeetTobyAtanwe_played is,
        //but check both, just in case
        if ((flags.GetBool('MeetTobyAtanwe_Played') || flags.GetBool('FemJCMeetTobyAtanwe_played')) &&
            !flags.GetBool('MS_LetTobyTakeYou_Rando'))
        {
            flags.SetBool('MeetTobyAtanwe_Played', False,, 12);
            flags.SetBool('FemJCMeetTobyAtanwe_played', False,, 12);
            flags.SetBool('MS_PlayerTeleported', False,, 12);
        }
    } else if (localURL == "11_PARIS_EVERETT" && flags != None) {
        //Reset this once you get to Everett, for backtracking purposes
        if (flags.GetBool('MS_LetTobyTakeYou_Rando')){
            flags.SetBool('MS_LetTobyTakeYou_Rando', False,, 12);
            flags.SetBool('MS_PlayerTeleported', True,, 12);
        }
    }

    Super.Timer();
}
