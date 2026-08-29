#ifdef injections
class DXRRepairBot merges RepairBot;
#else
class DXRRepairBot extends #var(prefix)RepairBot;
#endif

var travel int numUses;
var transient DXRando dxr;
var string baseName;
var int baseChargeAmount;

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
    if (baseChargeAmount==-1){
        baseChargeAmount=chargeAmount;
    }
    Super.StandStill();
    SetPropertyText("lowerThreshold", "0");// RSD
    HandlePerkLogic();

}
#endif

function HandlePerkLogic()
{
    local DeusExPlayer player;

    player = DeusExPlayer(GetPlayerPawn());
    chargeAmount = baseChargeAmount;

#ifdef gmdxae
    if (player!=None &&
        player.PerkManager!=None &&
        player.PerkManager.GetPerkWithClass(class'DeusEx.PerkMisfeatureExploit').bPerkObtained == true){

        //Base GMDX chargeAmount is 60, and with the perk, it does 90 (60 * 1.5 = 90)
        chargeAmount = chargeAmount * 1.5;
    }
#elseif gmdxnotae
    if (player!=None &&
        player.PerkNamesArray[21] == 1){
        //Base GMDX chargeAmount is 60, and with the perk, it does 90 (60 * 1.5 = 90)
        chargeAmount = chargeAmount * 1.5;
    }
#endif
}


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
        msg = msg $ ".  No charges left.";
    } else {
        msg = msg $ ".  " $ chargeRefreshTime $ "s until recharged.  ";
        if (uses == 1)
            msg = msg $ "1 charge left.";
        else if (uses > 0)
            msg = msg $ uses $ " charges left.";
    }

    PlayerToCharge.ClientMessage(msg);

    updateName();

    return chargedPoints;
}

#ifdef gmdxae
//Recharging wearable equipment
function ChargeEquipment(inventory EquipToCharge, DeusExPlayer EquipOwner)
{
    local int prevCharges;

    prevCharges = chargeMaxTimes;

    Super.ChargeEquipment(EquipToCharge,EquipOwner);

    //Charging equipment sometimes counts against the number of charges (based on difficulty)
    if (prevCharges>chargeMaxTimes){
        numUses++;
        updateName();
    }

}
#endif

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

//GMDX:AE Function
function bool HasChargesRemaining()
{
    return ChargesRemaining();
}

//#region CanCharge
#ifdef injections
simulated function bool CanCharge()
{
    if (_CanCharge()) {
        if (HasLimitedUses()) {
            return (GetRemainingUses()>0);
        } else {
            return True;
        }
    } else {
        return False;
    }
}
#elseif hx
simulated function bool CanCharge()
{
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

    if (Super.CanCharge()) {
        if (HasLimitedUses()) {
            return (GetRemainingUses()>0);
        } else {
            return True;
        }
    } else {
        return False;
    }
}
#else
simulated function bool CanCharge()
{
    if (Super.CanCharge()) {
        if (HasLimitedUses()) {
            return (GetRemainingUses()>0);
        } else {
            return True;
        }
    } else {
        return False;
    }
}
#endif
//#endregion

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

    if (EMPHitPoints<=0 || class'DXRFlags'.default.bZeroRando){
        LightType=LT_None;
    } else if(CanCharge()){
        LightHue=class'MenuChoice_ColorVision'.Static.GetReadyHue();
        LightType=LT_Steady;
    } else {
        LightHue=class'MenuChoice_ColorVision'.Static.GetNotReadyHue();
        if (HasLimitedUses() && ChargesRemaining()){
            LightType=LT_Pulse;
        } else {
            LightType=LT_Steady;
        }
    }
}

#ifdef gmdxae
simulated function ActivateRepairBotScreens(DeusExPlayer PlayerToDisplay)
{
    local int realChargeRefresh;
    local DXRando dxr;

    dxr = class'DXRando'.default.dxr;

    realChargeRefresh = chargeRefreshTime;

    Super.ActivateRepairBotScreens(PlayerToDisplay);

    if (dxr!=None && dxr.flags!=None && dxr.flags.settings.repairbotcooldowns>0){
        //If Medbot cooldowns are randomized, restore the previous cooldown
        chargeRefreshTime = realChargeRefresh;
    }
}
#endif

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
    baseChargeAmount=-1
}
