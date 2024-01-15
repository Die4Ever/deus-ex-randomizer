class DXRTrashCan4 injects #var(prefix)TrashCan4;

defaultproperties
{
     bGenerateTrash=False
}

function Destroyed()
{
    class'TrashCanCommon'.static.DestroyTrashCan(self, class'TrashBag');
    Super.Destroyed();
}
