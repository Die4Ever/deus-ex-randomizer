class DXRJunkieFemale injects JunkieFemale;

function Died(pawn Killer, name damageType, vector HitLocation)
{
    local DXRando dxr;

    Super.Died(Killer, damageType, HitLocation);
    if (FamiliarName == "Aimee") {
        foreach AllActors(class'DXRando', dxr) {
            class'DXREventsBase'.static.MarkBingoAsFailed(dxr, "AimeeLeMerchantLived");
            break;
        }
    }
}
