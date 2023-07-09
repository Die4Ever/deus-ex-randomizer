class DXRPinball injects #var(prefix)Pinball;

var bool bAlreadyUsed;

function Frob(actor Frobber, Inventory frobWith)
{
    local DXRando dxr;

    if (!bUsing && !bAlreadyUsed){
        bAlreadyUsed=True;
        foreach AllActors(class'DXRando', dxr) {
            class'DXREvents'.static.MarkBingo(dxr,"PinballWizard");
        }
    }

    Super.Frob(Frobber,frobWith);
}
