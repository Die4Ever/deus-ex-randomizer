#ifdef injections
class DXRMedicalBot merges MedicalBot;
#else
class DXRMedicalBot extends #var(prefix)MedicalBot;
#endif
var int numUses;

replication
{
    reliable if ( Role == ROLE_Authority )
        numUses;
}

function int HealPlayer(DeusExPlayer player)
{
    local int healAmount;

#ifdef injections
    healAmount = _HealPlayer(player);
#else
    healAmount = Super.HealPlayer(player);
#endif

    numUses++;

    return healAmount;
}

simulated function int GetMaxUses()
{
    local DXRando dxr;

    foreach AllActors(class'DXRando', dxr){
        return dxr.flags.settings.medbotuses;
    }

    return 0;

}

simulated function int GetRemainingUses()
{
    return (GetMaxUses() - numUses);
}

simulated function string GetRemainingUsesStr()
{
    local int uses;
    local string msg;

    uses = GetRemainingUses();

    if (uses == 1) {
        msg = " (1 Heal Left)";
    } else {
        msg = " ("$uses$" Heals Left)";
    }

    return msg;

}

simulated function bool HasLimitedUses()
{
     return (GetMaxUses() != 0);
}

simulated function bool HealsRemaining()
{
    return GetRemainingUses()!=0;
}

simulated function bool CanHeal()
{
#ifdef injections
    if (_CanHeal()) {
#else
    if (Super.CanHeal()) {
#endif
        if (HasLimitedUses()) {
            return (GetRemainingUses()>0);
        } else {
            return True;
        }
    } else {
        return False;
    }
}

simulated function Float GetRefreshTimeRemaining()
{
    local int timeRemaining;

    timeRemaining = healRefreshTime - (Level.TimeSeconds - lastHealTime);

    if (timeRemaining < 0) {
        timeRemaining = 0;
    }

    return timeRemaining;
}

defaultproperties
{
    bDetectable=false
    bIgnore=true
}
