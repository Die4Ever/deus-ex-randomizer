class DXRMission05 injects Mission05;


function FirstFrame()
{
    local bool metMiguel;

    if (localURL == "05_NYC_UNATCOMJ12LAB")
    {
        //In the vanilla mission script, Miguel gets destroyed if
        //you have met him, and he isn't following you when you enter.
        //Unmark his conversation as played for the duration of the
        //vanilla script.
        metMiguel=flags.GetBool('MeetMiguel_Played');
        if (metMiguel){
            flags.SetBool('MeetMiguel_Played',False,,6);
        }
    }

    Super.FirstFrame();

    if (localURL == "05_NYC_UNATCOMJ12LAB")
    {
        //Restore the conversation state if it had been played
        if (metMiguel){
            flags.SetBool('MeetMiguel_Played',True,,6);
        }
    }
}
