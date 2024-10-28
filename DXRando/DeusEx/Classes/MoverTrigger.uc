class MoverTrigger extends SequenceTrigger;

function CheckMovers()
{
	local Mover M;

	if (Event != '') {
        Super.CheckMovers();

		foreach AllActors(class'Mover', M, Event) {
            if (MultiMover(M) == None && ElevatorMover(M) == None) { // let Super.CheckMovers() handle these cases
			    M.InterpolateTo(SeqNum, M.MoveTime);
            }
		}
    }
}
