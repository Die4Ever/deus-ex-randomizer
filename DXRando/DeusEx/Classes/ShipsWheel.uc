class DXRShipsWheel injects #var(prefix)ShipsWheel;

var bool bAlreadyUsed;

function Frob(actor Frobber, Inventory frobWith)
{
	local #var(PlayerPawn) player;
    local DXRando      dxr;

	Super.Frob(Frobber, frobWith);

	player = #var(PlayerPawn)(Frobber);
    if (player!=None){
        if (!bAlreadyUsed){
            bAlreadyUsed = true;
            foreach AllActors(class'DXRando', dxr) {
                class'DXREvents'.static.MarkBingo(dxr,"SpinShipsWheel");
            }
        }
    }
}

defaultproperties
{
}
