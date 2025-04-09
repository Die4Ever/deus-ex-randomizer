class DXRShipsWheel injects #var(prefix)ShipsWheel;

var bool bAlreadyUsed;

function Frob(actor Frobber, Inventory frobWith)
{
    local #var(PlayerPawn) player;

    Super.Frob(Frobber, frobWith);

    player = #var(PlayerPawn)(Frobber);
    if (player!=None){
        if (!bAlreadyUsed){
            bAlreadyUsed = true;
            class'DXREvents'.static.MarkBingo("SpinShipsWheel");
        }
    }
}

defaultproperties
{
}
