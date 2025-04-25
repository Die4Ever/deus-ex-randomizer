class DXRDecoration merges DeusExDecoration;

function BaseChange()
{
    local Human p;
    // DXRando: check if we're being carried
    p = Human(base);
    if(p == None) {
        p = Human(GetPlayerPawn());
        if(p != None && p.CarriedDecoration == self) {
            p.ForcePutCarriedDecorationInHand();
            return;
        }
    }
    else if(p != None && p.CarriedDecoration != Self) {
        p.FinishDrop(self);
        return;
    }

    // back to vanilla code
    _BaseChange();
}
