class DXRMedicalBot merges MedicalBot;

var int numUses;

function int HealPlayer(DeusExPlayer player)
{
    local int healAmount;
    
    healAmount = _HealPlayer(player);
    
    numUses++;
    
    return healAmount;
}

function int GetMaxUses()
{
    local DeusExPlayer p;
    
    foreach AllActors(class'DeusExPlayer', p){
        return p.flagBase.GetInt('Rando_medbotuses');
    }
    
    return 0;
    
}

function int GetRemainingUses()
{   
    return (GetMaxUses() - numUses);
}

function string GetRemainingUsesStr()
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

function bool HasLimitedUses()
{
     return (GetMaxUses() != 0);
}

function bool HealsRemaining()
{
    return GetRemainingUses()!=0;
}

function bool CanHeal()
{
    if (_CanHeal()) {
        if (HasLimitedUses()) {
            return (GetRemainingUses()>0);
        } else {
            return True;
        }
    } else {
        return False;
    }
}

function Float GetRefreshTimeRemaining()
{
    local int timeRemaining;
    
    timeRemaining = healRefreshTime - (Level.TimeSeconds - lastHealTime);
    
    if (timeRemaining < 0) {
        timeRemaining = 0;
    }
    
    return timeRemaining;
}
