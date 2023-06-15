class DXRMission04 injects Mission04;

function Timer()
{
    local DXRMapVariants mapvariants;
    local string map;

    // do this for every map in this mission
    // if the player is "killed" after a certain flag, he is sent to mission 5
    if (flags != None && !flags.GetBool('MS_PlayerCaptured'))
    {
        if (flags.GetBool('TalkedToPaulAfterMessage_Played'))
        {
            if (Player.IsInState('Dying'))
            {
                flags.SetBool('MS_PlayerCaptured', True,, 5);
                Player.GoalCompleted('EscapeToBatteryPark');
                map = "05_NYC_UNATCOMJ12Lab";
                foreach AllActors(class'DXRMapVariants', mapvariants) {
                    map = mapvariants.VaryMap(map);
                    break;
                }
                Level.Game.SendPlayer(Player, map);
            }
        }
    }

    Super.Timer();
}
