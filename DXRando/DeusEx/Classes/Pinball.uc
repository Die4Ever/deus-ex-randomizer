class DXRPinball injects #var(prefix)Pinball;

var bool bAlreadyUsed;

function Frob(actor Frobber, Inventory frobWith)
{
    if (!bUsing && !bAlreadyUsed){
        bAlreadyUsed=True;
        class'DXREvents'.static.MarkBingo("PinballWizard");
    }

    Super.Frob(Frobber,frobWith);
}
