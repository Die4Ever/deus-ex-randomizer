class DXRDecoration merges DeusExDecoration;

singular function BaseChange()
{
    local Human p;
    // DXRando: check if we're being carried
    p = Human(GetPlayerPawn());
    if(p != None && p.CarriedDecoration == self) {
        p.ForcePutCarriedDecorationInHand();
        return;
    }

    // back to vanilla code
    _BaseChange();
}
