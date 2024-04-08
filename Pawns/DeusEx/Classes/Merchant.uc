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

#ifdef revision
function bool FilterDamageType(Pawn instigatedBy, Vector hitLocation,
                               Vector offset, Name damageType, optional bool bTestOnly)
#else
function bool FilterDamageType(Pawn instigatedBy, Vector hitLocation,
                               Vector offset, Name damageType)
#endif
{
    // Merchants aren't affected by radiation barrels
    if(damageType == 'Radiation')
        return false;
    return Super.FilterDamageType(instigatedBy, hitLocation, offset, damageType);
}

function Died(pawn Killer, name damageType, vector HitLocation)
{
    local DXRando dxr;

    Super.Died(Killer, damageType, HitLocation);
    if (FamiliarName == "Le Merchant") {
        foreach AllActors(class'DXRando', dxr) {
            class'DXREventsBase'.static.MarkBingoAsFailed(dxr, "AimeeLeMerchantLived");
            break;
        }
    }
}

defaultproperties
{
    CarcassType=Class'MerchantCarcass'
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
