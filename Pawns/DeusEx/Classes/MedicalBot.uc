#ifdef injections
class DXRMedicalBot merges MedicalBot;
#else
class DXRMedicalBot extends #var(prefix)MedicalBot;
#endif

var travel int numUses;

replication
{
    reliable if ( Role == ROLE_Authority )
        numUses;
}

#ifdef gmdx
function PostBeginPlay()
{
    Super.PostBeginPlay();
    healMaxTimes = GetMaxUses();
}

function StandStill()
{
    Super.StandStill();
    SetPropertyText("lowerThreshold", "0");// RSD
}
#endif

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

    if(#defined(vmd)) return 0;// disabled for VMD

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
#ifdef gmdx
    return Super.CanHeal();
#endif

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
    local float timeRemaining;

#ifdef injections
    timeRemaining = _GetRefreshTimeRemaining();
#else
    timeRemaining = Super.GetRefreshTimeRemaining();
#endif

    if (timeRemaining < 0) {
        timeRemaining = 0;
    }

    return timeRemaining;
}

function Explode(vector HitLocation)
{
    local Pawn oldInstigator;

    oldInstigator = Instigator;
    Instigator = self;
    Super.Explode(HitLocation);
    Instigator = oldInstigator;
}

defaultproperties
{
    bDetectable=false
    bIgnore=true
}
