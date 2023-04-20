class Merchant extends #var(prefix)Businessman3;

#ifdef vmd
function bool ShouldDoSinglePickPocket(DeusExPlayer Frobbie)
{
    return false;
}
#endif

//Oui Oui
function MakeFrench()
{
    MultiSkins[0]=Texture'DeusExCharacters.Skins.ChefTex0';
    MultiSkins[7]=Texture'DeusExCharacters.Skins.ChefTex3'; //Should he actually have the hat?
    CarcassType=Class'LeMerchantCarcass';
}

function bool FilterDamageType(Pawn instigatedBy, Vector hitLocation,
                               Vector offset, Name damageType)
{
    // Merchants aren't affected by radiation barrels
    if(damageType == 'Radiation')
        return false;
    return Super.FilterDamageType(instigatedBy, hitLocation, offset, damageType);
}

defaultproperties
{
    bImportant=True
    bDetectable=false
    bIgnore=true
    RaiseAlarm=RAISEALARM_Never
    Health=200
    HealthArmLeft=200
    HealthArmRight=200
    HealthHead=200
    HealthLegLeft=200
    HealthLegRight=200
    HealthTorso=200
    ReducedDamageType=Radiation
}
