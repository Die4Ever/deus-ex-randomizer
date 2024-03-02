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
