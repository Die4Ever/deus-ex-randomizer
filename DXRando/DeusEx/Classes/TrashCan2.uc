class DXRTrashCan2 injects #var(prefix)Trashcan2;

defaultproperties
{
     bGenerateTrash=False
}

function Destroyed()
{
    class'TrashCanCommon'.static.DestroyTrashCan(self, class'#var(prefix)TrashBag2');
    Super.Destroyed();
}
