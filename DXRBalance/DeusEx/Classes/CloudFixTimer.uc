class DXRCloud injects Cloud;

// HACK: duplicate the Flying state for savegame compatibility
auto simulated state Flying
{
}

simulated function Touch(actor Other)
{
    Super.Touch(Other);
    if(ScriptedPawn(Other) != None) {
        Other.TakeDamage(Damage, Instigator, Other.Location, vect(0,0,0), damageType);
    }
}
