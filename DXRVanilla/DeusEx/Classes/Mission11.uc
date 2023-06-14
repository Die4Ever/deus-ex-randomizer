class DXRMission11 injects Mission11;

function Timer()
{
    local DXRMapVariants mapvariants;
    local string map;

    if (localURL == "11_PARIS_UNDERGROUND" && flags != None)
    {
        // knock out the player and teleport him after this convo
        if (flags.GetBool('MeetTobyAtanwe_Played') &&
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
    }

    Super.Timer();
}
