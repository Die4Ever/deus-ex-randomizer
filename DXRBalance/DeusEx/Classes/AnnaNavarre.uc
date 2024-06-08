class DXRAnnaNavarre injects AnnaNavarre;

function Carcass SpawnCarcass()
{
    // always explode even if unconscious, to keep the dialog consistent
    Explode();
    return None;
}

function float ModifyDamage(int Damage, Pawn instigatedBy, Vector hitLocation,
                            Vector offset, Name damageType)
{
    // remove her full resistance to non lethal damage
    return Super(HumanMilitary).ModifyDamage(Damage, instigatedBy, hitLocation, offset, damageType);
}

function float ShieldDamage(name damageType)
{
    // move her resistances into shield so they are visible to the player
    if (damageType == 'Stunned' || damageType == 'KnockedOut' || damageType == 'Poison' || damageType == 'PoisonEffect')
        return 0;
    return Super.ShieldDamage(damageType);
}

// if her shields are down, allow her to be stunned/gassed
function GotoDisabledState(name damageType, EHitLocation hitPos)
{
    if(ShieldDamage(damageType) < 1) {
        if(EmpHealth > 0) {
            MaybeDrawShield();
            Super.GotoDisabledState(damageType, hitPos);
        }
        else
            Super(HumanMilitary).GotoDisabledState(damageType, hitPos);
    } else {
        Super.GotoDisabledState(damageType, hitPos);
    }
}
