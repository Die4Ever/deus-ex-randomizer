class DXRTrashCan3 injects #var(prefix)TrashCan3;

defaultproperties
{
     bGenerateTrash=False
}

function Destroyed()
{
    class'TrashContainerCommon'.static.DestroyTrashCan(self, class'#var(prefix)TrashBag');
    Super.Destroyed();
}
