class DXRMJ12Commando injects MJ12Commando;

function float ModifyDamage(int Damage, Pawn instigatedBy, Vector hitLocation,
                            Vector offset, Name damageType)
{
    if(damageType == 'Sabot') Damage *= 2;
    return Super.ModifyDamage(Damage, instigatedBy, hitLocation, offset, damageType);
}

function PlayPanicRunning()
{
    PlayRunning();
}

defaultproperties
{
    BurnPeriod=5.0
}
