class DXRTrashbag2 injects #var(prefix)Trashbag2;

function Destroyed()
{
    local DXRando dxr;

    if (IsInState('Burning')){
        foreach AllActors(class'DXRando',dxr){
            class'DXREvents'.static.MarkBingo(dxr,"BurnTrash");
        }
    }
    Super.Destroyed();
}
