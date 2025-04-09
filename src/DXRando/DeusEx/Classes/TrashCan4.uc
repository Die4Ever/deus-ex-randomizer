class DXRTrashCan4 injects #var(prefix)TrashCan4;

defaultproperties
{
     bGenerateTrash=False
}

function Destroyed()
{
    class'TrashContainerCommon'.static.DestroyTrashCan(self, class'#var(prefix)TrashBag');
    Super.Destroyed();
}
