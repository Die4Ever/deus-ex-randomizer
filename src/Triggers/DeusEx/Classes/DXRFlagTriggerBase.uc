// Base class for flag triggers with non-bool values. Based on the original FlagTrigger.
class DXRFlagTriggerBase extends Trigger abstract;

var() name flagName;
var() bool bSetFlag;
var() bool bTrigger;
var() bool bWhileStandingOnly;
var() int flagExpiration;
var() int oldExpiration;
var() bool hasOldValue;

function bool SetFlagValue(optional #var(PlayerPawn) player);
function SaveOldValue(optional #var(PlayerPawn) player);
function bool RestoreOldValue(optional #var(PlayerPawn) player);
function bool DeleteFlag(optional #var(PlayerPawn) player);

function bool IsFlagValueCurrent(optional #var(PlayerPawn) player);
function bool FlagExists(optional #var(PlayerPawn) player);

function Touch(Actor Other)
{
	local #var(PlayerPawn) player;

	if (IsRelevant(Other)) {
		player = #var(PlayerPawn)(GetPlayerPawn());
		if (player != None) {
			if (bSetFlag)
                SetFlagValue(player);

			if (bTrigger && IsFlagValueCurrent(player))
                Super.Touch(Other);
		}
	}
}

function UnTouch(Actor Other)
{
	local #var(PlayerPawn) player;

	if (bWhileStandingOnly) {
		if (IsRelevant(Other)) {
			player = #var(PlayerPawn)(GetPlayerPawn());
			if (player != None) {
				if (bTrigger && IsFlagValueCurrent(player))
                    Super.UnTouch(Other);

				if (bSetFlag)
					FlipValue();
			}
		}
	}
}

function Trigger(Actor Other, Pawn Instigator)
{
	local #var(PlayerPawn) player;
	local Actor A;

	player = #var(PlayerPawn)(GetPlayerPawn());
	if (player != None) {
		if (bSetFlag)
            SetFlagValue(player);

		if (bTrigger && IsFlagValueCurrent(player)) {
            if (Event != '')
                foreach AllActors(class 'Actor', A, Event)
                    A.Trigger(player, Instigator);

            Super.Trigger(Other, Instigator);
        }
	}
}

function UnTrigger(Actor Other, Pawn Instigator)
{
	local #var(PlayerPawn) player;
	local Actor A;

	if (bWhileStandingOnly) {
		player = #var(PlayerPawn)(GetPlayerPawn());
		if (player != None) {
			if (bTrigger && IsFlagValueCurrent(player)) {
                if (Event != '')
                    foreach AllActors(class 'Actor', A, Event)
                        A.UnTrigger(player, Instigator);

                Super.UnTrigger(Other, Instigator);
            }

			if (bSetFlag)
                FlipValue(player);
		}
	}
}

// A bit more complicated than negating a bool
// Sets flag to flagValue if it's currently different
// Sets flag to the previous value, or deletes it, if it isn't
function FlipValue(optional #var(PlayerPawn) player)
{
    local int currentValue;

    player = GetPlayer(player);
    if (IsFlagValueCurrent(player) == false) {
        hasOldValue = FlagExists(player);
        if (hasOldValue)
            SaveOldValue(player);
        SetFlagValue(player);
    } else {
        if (hasOldValue)
            RestoreOldValue(player);
        else
            DeleteFlag(player);
    }
}

function #var(PlayerPawn) GetPlayer(optional #var(PlayerPawn) player)
{
    if (player == None)
        return #var(PlayerPawn)(GetPlayerPawn());
    return player;
}

defaultproperties
{
     bSetFlag=True
     flagExpiration=-1
     bTriggerOnceOnly=True
     CollisionRadius=96.000000
}
