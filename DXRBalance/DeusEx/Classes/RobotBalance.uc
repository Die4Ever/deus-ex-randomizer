class DXRRobotBalance shims Robot;

function TakeDamageBase(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType, bool bPlayAnim)
{
    // disable the damage resistance for plasma
    if(damageType == 'Burned') Damage *= 4;
    Super.TakeDamageBase(Damage, instigatedBy, hitLocation, momentum, damageType, bPlayAnim);
}

defaultproperties
{
    BaseAccuracy=0.1
}
