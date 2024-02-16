class DXRTrashbag2 injects #var(prefix)Trashbag2;

function Destroyed()
{
    local DXRando dxr;

    if (IsInState('Burning')){
        foreach AllActors(class'DXRando',dxr){
            class'DXREvents'.static.MarkBingo(dxr,"BurnTrash");
        }
    }

    class'TrashContainerCommon'.static.DestroyTrashbag(self);

    Super.Destroyed();
}

defaultproperties
{
     bGenerateTrash=False
}
