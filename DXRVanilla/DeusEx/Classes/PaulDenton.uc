class DXRPaulDenton injects PaulDenton;

function Frob(Actor frobber, Inventory frobWith)
{
    local DXRando dxr;

    Super.Frob(frobber, frobWith);

    foreach AllActors(class'DXRando', dxr) {
        if (dxr.flagbase.GetBool('M04MeetGateGuard_Played') && dxr.flagbase.GetBool('NSFSignalSent') == false) {
            // these conditions allow the "M04PlayerLikesUNATCO" conversation to start
            class'DXREvents'.static.MarkBingo(dxr, "UnatcoDefectionRefused");
        }
        break;
    }
}
