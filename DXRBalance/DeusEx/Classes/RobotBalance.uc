class DXRRobotBalance shims Robot;

function TakeDamageBase(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType, bool bPlayAnim)
{
    // robots now have 25% damage resistance for plasma instead of 75%
    if(damageType == 'Burned' && class'MenuChoice_BalanceEtc'.static.IsEnabled()) Damage *= 3;

    Super.TakeDamageBase(Damage, instigatedBy, hitLocation, momentum, damageType, bPlayAnim);
}

//Copied from the various Human classes.  Makes it more possible to filter out
//accidentally walking on one vs actively jumping on one
function bool WillTakeStompDamage(actor stomper)
{
	// This blows chunks!
	if (stomper.IsA('PlayerPawn') && (GetPawnAllianceType(Pawn(stomper)) != ALLIANCE_Hostile))
		return false;
	else
		return true;
}

function BeginPlay()
{
    if(class'MenuChoice_BalanceEtc'.static.IsEnabled()) {
        BaseAccuracy=0.1;
    } else {
        BaseAccuracy=0;
    }
    default.BaseAccuracy=BaseAccuracy;
    Super.BeginPlay();
}

defaultproperties
{
    BaseAccuracy=0.1
}
