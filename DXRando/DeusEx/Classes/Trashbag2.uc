class DXRTrashbag2 injects #var(prefix)Trashbag2;

function Destroyed()
{
    if (IsInState('Burning')){
        class'DXREvents'.static.MarkBingo("BurnTrash");
    }

    class'TrashContainerCommon'.static.DestroyTrashbag(self);

    Super.Destroyed();
}

function SupportActor(Actor standingActor)
{
	if (standingActor != None && standingActor.Mass>=35){
        bCanBeBase=False;
        TakeDamage(HitPoints,standingActor.Instigator, standingActor.Location, 0.2*standingActor.Velocity, 'stomped');
    }
    Super.SupportActor(standingActor);
}

defaultproperties
{
     bGenerateTrash=False
}
