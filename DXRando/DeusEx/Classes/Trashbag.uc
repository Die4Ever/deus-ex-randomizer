class DXRTrashbag injects #var(prefix)Trashbag;

function Destroyed()
{
    local DXRando dxr;

    if (IsInState('Burning')){
        foreach AllActors(class'DXRando',dxr){
            class'DXREvents'.static.MarkBingo(dxr,"BurnTrash");
        }
    }

    class'TrashContainerCommon'.static.GenerateTrashPaper(self, 0.5);

    Super.Destroyed();
}

defaultproperties
{
     bGenerateTrash=False
}
