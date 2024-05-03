class ChargedPickup merges ChargedPickup;
// need to figure out states compatibility https://github.com/Die4Ever/deus-ex-randomizer/issues/135

var int ticksRemaining;
var bool lastSound;

const DEFAULT_TIME = 10;
const HALF_TIME = 5;
const QUARTER_TIME = 2;
const LAST_SECONDS = 1;

function PostPostBeginPlay()
{
    SoundVolume = 50;
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
    local int drain;

    drain = _CalcChargeDrain(Player);
    if( drain < 1 ) drain = 1;
    return drain;
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
    local int endDrain;

    endDrain = CalcChargeDrain(Player) * 30;

    if(ticksRemaining-- <= 0){

        PlayTickSound(Player);

        if (Charge > (Default.Charge/2)){
            ticksRemaining=DEFAULT_TIME;
        } else if (charge < endDrain){
            ticksRemaining=LAST_SECONDS;
        } else if (Charge < (Default.Charge/4)){
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
