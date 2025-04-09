class DXRMoverSequenceTrigger extends SequenceTrigger;

function CheckMovers()
{
    local Mover M;

    if (Event == '') return;

    foreach AllActors(class'Mover', M, Event) {
        if (MultiMover(M) != None)
            MultiMover(M).SetSeq(SeqNum);
        else if (ElevatorMover(M) != None)
            ElevatorMover(M).SetSeq(SeqNum);
        else
            M.InterpolateTo(SeqNum, M.MoveTime);
    }
}
