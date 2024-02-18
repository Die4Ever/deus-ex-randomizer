class DXRTrashbag injects #var(prefix)Trashbag;

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
