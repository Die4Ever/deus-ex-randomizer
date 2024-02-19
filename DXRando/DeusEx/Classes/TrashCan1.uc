class DXRTrashCan1 injects #var(prefix)TrashCan1;

defaultproperties
{
     bGenerateTrash=False
}

function Destroyed()
{
    class'TrashCanCommon'.static.DestroyTrashCan(self, class'#var(prefix)TrashBag');
    Super.Destroyed();
}
