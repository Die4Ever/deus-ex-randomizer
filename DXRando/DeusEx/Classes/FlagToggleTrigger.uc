class FlagToggleTrigger extends Trigger;

var name flagName;
var int flagExpiration;

static function FlagToggleTrigger CreateFTT(Actor a, name tag, name flagName, optional int flagExpiration)
{
    local FlagToggleTrigger ftt;

    if (a == None || tag == '' || flagName == '') return None;

    ftt = a.Spawn(class'FlagToggleTrigger',, tag);

    ftt.flagName = flagName;
    if (flagExpiration == 0)
        ftt.flagExpiration = 999;
    else
        ftt.flagExpiration = flagExpiration;

    return ftt;
}

function Trigger(Actor Other, Pawn Instigator)
{
    local FlagBase flagbase;
    local bool oldState;

    flagbase = DeusExPlayer(GetPlayerPawn()).flagbase;

    oldState = flagbase.getBool(flagName);
    flagbase.setBool(flagName, !oldState,, flagExpiration);

    Super.Trigger(Other, Instigator);
}

defaultproperties
{
    bCollideActors=false
}
