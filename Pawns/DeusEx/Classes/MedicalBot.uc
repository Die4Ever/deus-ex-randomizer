#ifdef injections
class DXRMedicalBot merges MedicalBot;
#else
class DXRMedicalBot extends #var(prefix)MedicalBot;
#endif

var travel int numUses;
var transient DXRando dxr;
var bool augsOnly;
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
    healMaxTimes = GetMaxUses();
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

function int HealPlayer(DeusExPlayer PlayerToHeal)
{
    local int healedPoints, uses;
    local string msg;

#ifdef injections
    // vanilla HealPlayer but with a different client message
    if (Human(PlayerToHeal) != None) {
        healedPoints = Human(PlayerToHeal)._HealPlayer(healAmount);
        numUses++;

        lastHealTime = Level.TimeSeconds;
        uses = GetRemainingUses();

        if (healedPoints == 1)
            msg = "Healed 1 point";
        else
            msg = "Healed " $ healedPoints $ " points";
        if (healedPoints < healAmount)
            msg = msg $ " (max " $ healAmount $ ")";

        if (uses == 0) {
            msg = msg $ ". No heals left.";
        } else {
            msg = msg $ ". " $ healRefreshTime $ "s until recharged. ";
            if (uses == 1)
                msg = msg $ "1 heal left.";
            else
                msg = msg $ uses $ " heals left.";
        }

        PlayerToHeal.ClientMessage(msg);
    }
#else
    healedPoints = Super.HealPlayer(player);
    numUses++;
    // don't show multiple client messages
#endif

    updateName();

    return healedPoints;
}

simulated function int GetMaxUses()
{
    if(#defined(vmd)) return 0;// disabled for VMD

    if(dxr == None) {
        foreach AllActors(class'DXRando', dxr){
            return dxr.flags.settings.medbotuses;
        }
        return 0;
    }

    return dxr.flags.settings.medbotuses;
}

simulated function int GetRemainingUses()
{
    if (augsOnly)
        return 0;
    else
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
        return " (No Heals Left)";
    } else if (uses == 1) {
        msg = " (1 Heal Left)";
    } else {
        msg = " ("$uses$" Heals Left)";
    }

    return msg;

}

simulated function bool HasLimitedUses()
{
     return (GetMaxUses() != 0 || augsOnly);
}

simulated function bool HealsRemaining()
{
    return GetRemainingUses() > 0;
}

simulated function bool CanHeal()
{
#ifdef gmdx
    return Super.CanHeal();
#endif

#ifdef injections
    if (_CanHeal())
#else
    if (Super.CanHeal())
#endif
    {
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

function MakeAugsOnly()
{
    augsOnly = true;
    MultiSkins[0] = Texture'AugBotTex1';
}

function Tick(float delta)
{
    Super.Tick(delta);

    if (!augsOnly && baseName == "" && familiarName != "") {
        baseName = familiarName;
        updateName();
    }

    if (EMPHitPoints<=0){
        LightType=LT_None;
    } else if(CanHeal()){
        LightHue=89;
        LightType=LT_Steady;
    } else {
        LightHue=255;
        if (HasLimitedUses() && HealsRemaining()){
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
