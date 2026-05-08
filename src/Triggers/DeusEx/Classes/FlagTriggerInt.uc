// FlagTrigger, but for ints.
class DXRFlagTriggerInt extends Trigger;

var() name flagName;
var() int flagValue;
var() bool bSetFlag;
var() bool bTrigger;
var() bool bWhileStandingOnly;
var() int flagExpiration;
var() int oldValue;
var() bool hasOldValue;

function Touch(Actor Other)
{
	local #var(PlayerPawn) player;

	if (IsRelevant(Other)) {
		player = #var(PlayerPawn)(GetPlayerPawn());
		if (player != None) {
			if (bSetFlag)
                SetFlag(flagValue);

			if (bTrigger)
				if (player.flagBase.GetInt(flagName) == flagValue)
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
				if (bTrigger)
					if (player.flagBase.GetInt(flagName) == flagValue)
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
            SetFlag(flagValue);

		if (bTrigger)
			if (player.flagBase.GetInt(flagName) == flagValue) {
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
			if (bTrigger)
				if (player.flagBase.GetInt(flagName) == flagValue) {
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
    currentValue = player.flagBase.GetInt(flagName);
    if (currentValue != flagValue) {
        hasOldValue = player.flagbase.CheckFlag(flagName, FLAG_Int);
        oldValue = currentValue; // just always set it here instead of branching; it doesn't change anything
        SetFlag(flagValue);
    } else {
        if (hasOldValue)
            SetFlag(oldValue);
        else
            player.flagbase.DeleteFlag(flagName, FLAG_Int);
    }
}

function SetFlag(int value, optional #var(PlayerPawn) player)
{
    player = GetPlayer(player);
    if (flagExpiration == -1)
        player.flagBase.SetInt(flagName, value);
    else
        player.flagBase.SetInt(flagName, value,, flagExpiration);
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
