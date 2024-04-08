class DXRJuanLebedev injects JuanLebedev;

function Died(pawn Killer, name damageType, vector HitLocation)
{
    local DXRando dxr;

    Super.Died(Killer, damageType, HitLocation);
    foreach AllActors(class'DXRando', dxr) {
        class'DXREventsBase'.static.MarkBingoAsFailed(dxr, "LebedevLived");
        break;
    }
}
