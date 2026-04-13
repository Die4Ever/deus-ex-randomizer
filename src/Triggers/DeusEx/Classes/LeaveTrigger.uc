class LeaveTrigger extends Trigger;

function Touch(Actor Other)
{
    Super.Touch(Other);

    if (IsRelevant(Other))
    {
        MakeEmLeave(Other);
        if(bTriggerOnceOnly) Destroy();
    }
}

event Trigger( Actor Other, Pawn EventInstigator )
{
    MakeEmLeave(EventInstigator); //I think this is more correct than Other, probably?
    if(bTriggerOnceOnly) Destroy();
}

function MakeEmLeave(Actor Other)
{
    local Actor a;

    if (event==''){
        //No event will just make the actor that triggered this go away
        if (Other!=None){
            Other.bTransient=true;
        }
        return;
    }

    foreach AllActors(class'Actor',a,event){
        a.bTransient=true;
    }
}


defaultproperties
{
    bCollideActors=true
    bCollideWorld=false
    bBlockActors=false
    bBlockPlayers=false
}
