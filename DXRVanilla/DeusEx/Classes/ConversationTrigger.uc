class ConversationTrigger injects ConversationTrigger;

// Lay D Denton compatibility
singular function Trigger(Actor Other, Pawn Instigator)
{
    local DeusExPlayer Player;
    local Name oldConTag;
    oldConTag = ConversationTag;
    Player = DeusExPlayer(Other);

    if ((BindName != "") && (ConversationTag != ''))
    {
        if ((Player.FlagBase != None) && (Player.FlagBase.GetBool('LDDPJCIsFemale')))
        {
            ConversationTag = Player.FlagBase.StringToName("FemJC"$string(ConversationTag));
        }
    }
    Super.Trigger(Other, Instigator);
    ConversationTag = oldConTag;
}

singular function Touch(Actor Other)
{
    local DeusExPlayer Player;
    local Name oldConTag;
    oldConTag = ConversationTag;
    Player = DeusExPlayer(Other);

    if ((BindName != "") && (ConversationTag != ''))
    {
        if ((Player.FlagBase != None) && (Player.FlagBase.GetBool('LDDPJCIsFemale')))
        {
            ConversationTag = Player.FlagBase.StringToName("FemJC"$string(ConversationTag));
        }
    }
    Super.Touch(Other);
    ConversationTag = oldConTag;
}
