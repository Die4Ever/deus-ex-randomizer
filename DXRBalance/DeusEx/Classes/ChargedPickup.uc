class ChargedPickup merges ChargedPickup;
// need to figure out states compatibility https://github.com/Die4Ever/deus-ex-randomizer/issues/135

var int ticksRemaining;
var bool lastSound;

const DEFAULT_TIME = 10;
const HALF_TIME = 5;
const QUARTER_TIME = 2;
const LAST_SECONDS = 1;

function BeginPlay()
{
    FixChargeRounding();
    Super.BeginPlay();
}

function PostPostBeginPlay()
{
    SoundVolume = 50;
    FixChargeRounding();
    Super.PostPostBeginPlay();
}

function FixChargeRounding()
{// compatibility with old save games, without breaking travel
    if(!IsActive() && Charge == default.Charge) {
        Charge = default.Charge * 100;
    }
}

simulated function Float GetCurrentCharge()
{
    return Float(Charge) / Float(Default.Charge);
}

function ChargedPickupBegin(DeusExPlayer Player)
{
    local Human p;
    if(bOneUseOnly) {
        p = Human(Owner);
        if( p != None ) {
            if(p.InHand == self) {
                p.PutInHand(None);
                p.UpdateInHand();
            }
            p.HideInventory(self);
        }
        bDisplayableInv = false;
    }
    ticksRemaining=DEFAULT_TIME;
    _ChargedPickupBegin(Player);
}

simulated function int CalcChargeDrain(DeusExPlayer Player)
{
    local float skillValue;
    local float drain;

    drain = 400.0;// multiplied by 100 to fix rounding issues with ints
    skillValue = 1.0;

    if (skillNeeded != None)
        skillValue = Player.SkillSystem.GetSkillLevelValue(skillNeeded);
    drain *= skillValue;

    return Max(Int(drain), 1);
}

// overriding the Pickup class's function returning true, we return false in order to allow the pickup to happen
// if we don't do this, then Pickup will return true because bDisplayableInv is false
function bool HandlePickupQuery( inventory Item )
{
    if ( Item.Class == Class )
        return false;
    return Super.HandlePickupQuery(Item);
}

function PlayTickSound(DeusExPlayer Player)
{
        if (class'MenuChoice_ChargeTimer'.Default.enabled==False){return;}

        //Always play the sound from the player themselves
        //Use different audio slots so the sounds can theoretically overlap
        if (lastSound){
            Player.PlaySound(sound'TimerTick',SLOT_Misc);
        } else {
            Player.PlaySound(sound'TimerTock',SLOT_None);
        }
        lastSound=!lastSound;
}

function HandleTickSound(DeusExPlayer Player)
{
    local int endDrain, defaultCharge;

    endDrain = CalcChargeDrain(Player) * 30;
    defaultCharge = default.Charge * 100;

    if(ticksRemaining-- <= 0){

        PlayTickSound(Player);

        if (Charge > (defaultCharge/2)){
            ticksRemaining=DEFAULT_TIME;
        } else if (charge < endDrain){
            ticksRemaining=LAST_SECONDS;
        } else if (Charge < (defaultCharge/4)){
            ticksRemaining=QUARTER_TIME;
        } else {
            ticksRemaining=HALF_TIME;
        }
    }
}

function ChargedPickupUpdate(DeusExPlayer Player)
{
    _ChargedPickupUpdate(Player);

    //Crowd Control timers should never tick
    if (DXRandoCrowdControlTimer(Self)==None){
        HandleTickSound(Player);
    }
}

// default Charge was 2000, which is used for hazmats and rebreathers
defaultproperties
{
    Charge=1500
}
