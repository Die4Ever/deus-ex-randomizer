class SmugglerElevatorTracker extends Trigger;

function Trigger(Actor Other, Pawn Instigator)
{
    local DXRando dxr;
    local int expiration;
    local bool oldState;

    foreach AllActors(class'DXRando', dxr) break;

    switch(dxr.localURL) {
        case "02_NYC_STREET":
        case "02_NYC_SMUG":
            expiration = 3;
            break;
        case "04_NYC_STREET":
        case "04_NYC_SMUG":
            expiration = 5;
            break;
        case "08_NYC_STREET":
        case "08_NYC_SMUG":
            expiration = 9;
            break;
    }

    oldState = dxr.flagbase.getBool('DXRSmugglerElevatorUsed');
    dxr.flagbase.setBool('DXRSmugglerElevatorUsed', !oldState,, expiration);

    Super.Trigger(Other, Instigator);
}
