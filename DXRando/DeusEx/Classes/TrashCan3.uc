class DXRTrashCan3 injects #var(prefix)TrashCan3;

defaultproperties
{
     bGenerateTrash=False
}

function Destroyed()
{
    class'TrashCanCommon'.static.DestroyTrashCan(self, class'TrashBag');
    Super.Destroyed();
}
