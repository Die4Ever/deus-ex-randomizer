class DXRRobotBalance shims Robot;

function TakeDamageBase(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType, bool bPlayAnim)
{
    // disable the damage resistance for plasma
    if(damageType == 'Burned') Damage *= 4;
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

defaultproperties
{
    BaseAccuracy=0.1
}
