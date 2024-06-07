#ifdef injections
class DXRRepairBot merges RepairBot;
#else
class DXRRepairBot extends #var(prefix)RepairBot;
#endif

var travel int numUses;
var transient DXRando dxr;
var string baseName;

replication
{
    reliable if ( Role == ROLE_Authority )
        numUses;
}

#ifdef gmdx
function PostBeginPlay()
{
    Super.PostBeginPlay();
    chargeMaxTimes = GetMaxUses();
}

function StandStill()
{
    Super.StandStill();
    SetPropertyText("lowerThreshold", "0");// RSD
}
#endif

function updateName()
{
    familiarName = baseName $ GetRemainingUsesStr();
    unfamiliarName = familiarName;
}

function int ChargePlayer(DeusExPlayer PlayerToCharge)
{
    local int chargedPoints, uses;
    local string msg;

#ifdef injections
    chargedPoints = _ChargePlayer(PlayerToCharge);
#else
    chargedPoints = Super.ChargePlayer(PlayerToCharge);
#endif

    numUses++;

    uses = GetRemainingUses();
    if (chargedPoints == 1)
        msg = "Charged 1 point";
    else
        msg = "Charged " $ chargedPoints $ " points";
    if (chargedPoints < chargeAmount)
        msg = msg $ " (max " $ chargeAmount $ ")";

    if (uses == 0) {
        msg = msg $ ". No charges left.";
    } else {
        msg = msg $ ". " $ chargeRefreshTime $ "s until recharged. ";
        if (uses == 1)
            msg = msg $ "1 charge left.";
        else
            msg = msg $ uses $ " charges left.";
    }

    PlayerToCharge.ClientMessage(msg);

    updateName();

    return chargedPoints;
}

simulated function int GetMaxUses()
{
    if(#defined(vmd)) return 0;// disabled for VMD

    if(dxr == None) {
        foreach AllActors(class'DXRando', dxr){
            return dxr.flags.settings.repairbotuses;
        }
        return 0;
    }

    return dxr.flags.settings.repairbotuses;
}

simulated function int GetRemainingUses()
{
    return (GetMaxUses() - numUses);
}

simulated function string GetRemainingUsesStr()
{
    local int uses;
    local string msg;

    if(#defined(vmd)) return "";

    uses = GetRemainingUses();

    if(!HasLimitedUses()) {
        return msg;
    }
    else if (uses == 0) {
        msg = " (No Charges Left)";
    } else if (uses == 1) {
        msg = " (1 Charge Left)";
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
    local DXRMachines m;

    if(dxr == None) {
        foreach AllActors(class'DXRando', dxr) { break; }
    }
    if(dxr != None)
        m = DXRMachines(dxr.FindModule(class'DXRMachines'));
    if(m != None) {
        m.RandoRepairBot(self, dxr.flags.settings.repairbotamount, dxr.flags.settings.repairbotcooldowns);
    }
#endif

#ifdef gmdx
    return Super.CanCharge();
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

function Tick(float delta)
{
    Super.Tick(delta);

    if (basename == "" && familiarName != "") {
        baseName = familiarName;
        updateName();
    }

    if (EMPHitPoints<=0){
        LightType=LT_None;
    } else if(CanCharge()){
        LightHue=89;
        LightType=LT_Steady;
    } else {
        LightHue=255;
        if (HasLimitedUses() && ChargesRemaining()){
            LightType=LT_Pulse;
        } else {
            LightType=LT_Steady;
        }
    }
}

defaultproperties
{
    bDetectable=false
    bIgnore=true
    LightType=LT_Steady
    LightEffect=LE_None
    LightBrightness=160
    LightRadius=6
    LightHue=89
    LightPeriod=25
}
