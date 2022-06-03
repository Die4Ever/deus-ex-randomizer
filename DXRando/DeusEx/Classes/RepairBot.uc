#ifdef injections
class DXRRepairBot merges RepairBot;
#else
class DXRRepairBot extends #var(prefix)RepairBot;
#endif

var int numUses;

replication
{
    reliable if ( Role == ROLE_Authority )
        numUses;
}

function int ChargePlayer(DeusExPlayer PlayerToCharge)
{
    local int chargeAmount;

#ifdef injections
    chargeAmount = _ChargePlayer(PlayerToCharge);
#else
    chargeAmount = Super.ChargePlayer(PlayerToCharge);
#endif

    numUses++;

    return chargeAmount;
}

simulated function int GetMaxUses()
{
    local DXRando dxr;

    foreach AllActors(class'DXRando', dxr){
        return dxr.flags.settings.repairbotuses;
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
        msg = " (1 Charges Left)";
    } else {
        msg = " ("$uses$" Charges Left)";
    }

    return msg;
}

simulated function bool HasLimitedUses()
{
     return (GetMaxUses() != 0);
}

simulated function bool ChargesRemaining()
{
    return GetRemainingUses()!=0;
}

simulated function bool CanCharge()
{
#ifdef hx
    // hx doesn't have replication for our randomized variables
    local DXRando dxr;
    local DXRMachines m;
    foreach AllActors(class'DXRando', dxr) { break; }
    m = DXRMachines(dxr.FindModule(class'DXRMachines'));
    if(m != None) {
        m.RandoRepairBot(self, dxr.flags.settings.repairbotamount, dxr.flags.settings.repairbotcooldowns);
    }
#endif

#ifdef injections
    if (_CanCharge()) {
#else
    if (Super.CanCharge()) {
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

    timeRemaining = chargeRefreshTime - (Level.TimeSeconds - lastChargeTime);

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
