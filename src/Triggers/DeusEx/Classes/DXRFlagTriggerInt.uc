class DXRFlagTriggerInt extends DXRFlagTriggerBase;

var() int flagValue;
var() int oldValue;

function bool SetFlagValue(optional #var(PlayerPawn) player)
{
    if (flagExpiration == -1)
        return GetPlayer(player).flagBase.SetInt(flagName, flagValue);
    else
        return GetPlayer(player).flagBase.SetInt(flagName, flagValue,, flagExpiration);
}

function SaveOldValue(optional #var(PlayerPawn) player)
{
    player = GetPlayer(player);
    oldValue = player.flagBase.GetInt(flagName);
    oldExpiration = player.flagBase.GetExpiration(flagName, FLAG_Int);
}

function bool RestoreOldValue(optional #var(PlayerPawn) player)
{
    return GetPlayer(player).flagBase.SetInt(flagName, oldValue,, oldExpiration);
}

function bool DeleteFlag(optional #var(PlayerPawn) player)
{
    return GetPlayer(player).flagbase.DeleteFlag(flagName, FLAG_Int);
}

function bool IsFlagValueCurrent(optional #var(PlayerPawn) player)
{
    return GetPlayer(player).flagbase.GetInt(flagName) == flagValue;
}

function bool FlagExists(optional #var(PlayerPawn) player)
{
    return GetPlayer(player).flagbase.CheckFlag(flagName, FLAG_Int);
}
