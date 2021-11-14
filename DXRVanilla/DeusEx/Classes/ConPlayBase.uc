class ConPlayBase injects ConPlayBase;

// Lay D Denton compatibility
function SetPlayedFlag()
{
    local Name flagName;
    
    local string TFlagBarf, TSearch;

    Super.SetPlayedFlag();

    if (con != None)
    {
        //LDDP, 10/28/21: For faster one-line tweaking if we change convo prefix later.
        TSearch = "FemJC";
        
        //LDDP, 10/25/21: Mark male equivalent convos as done when female convos are done.
        if ((Player.FlagBase.GetBool('LDDPJCIsFemale')) && (Left(Con.ConName, Len(TSearch)) ~= TSearch))
        {
            TFlagBarf = con.conName $ "_Played";
            TFlagBarf = Right(TFlagBarf, Len(TFlagBarf)-Len(TSearch));
            
            flagName = player.rootWindow.StringToName( TFlagBarf );
            if (!player.flagBase.GetBool(flagName))
            {
                // Add a flag noting that we've finished this conversation.
                player.flagBase.SetBool(flagName, True);
            }
        }
    }
}
