class ElevatorMover merges ElevatorMover;
// can't do injects because it uses a state

var float lastTime;
var float moveSpeed;

function bool EncroachingOn( actor Other )
{
    if( Inventory(Other) != None ) {
        return false;
    }
    if( EncroachDamage < 10 && #var(PlayerPawn)(Other) == None ) {
        Other.TakeDamage( 1000, Instigator, Other.Location, vect(0,0,0), 'Crushed' );
        Other.TakeDamage( 1000, Instigator, Other.Location, vect(0,0,0), 'Exploded' );
        return false;
    }
    Super.EncroachingOn(Other);
    return false;
}

function float GetMoveSpeed()
{
    // assumes no valid KeyPos elements after the first are (0, 0, 0)
    local float maxDist;
    local int i, j;

    if (moveSpeed == 0.0) {
        for (i = 0; i < ArrayCount(KeyPos); i++) {
            for (j = i + 1; j < ArrayCount(KeyPos); j++) {
                if (KeyPos[j] == vect(0.0, 0.0, 0.0)) continue;
                maxDist = Max(maxDist, VSize(KeyPos[i] - KeyPos[j]));
            }
        }
        moveSpeed = maxDist / MoveTime;
    }

    return moveSpeed;
}

function SetSeq(int seqnum)
{
    local bool oldSeq;
    local int prevKeyNum;
    local float dist;

    if( MoveTime/2 < Level.TimeSeconds-lastTime )
        oldSeq = true;

    dist = VSize(BasePos + KeyPos[seqnum] - Location);

    if (KeyPos[0] == vect(0.0, 0.0, 0.0)) {
        MoveTime = dist / GetMoveSpeed();
    }

    if ( bIsMoving && !oldSeq )
        return;

    if (KeyNum != seqnum || oldSeq)
    {
        prevKeyNum = KeyNum;
        KeyNum = seqnum;

        GotoState('ElevatorMover', 'Next');

        if( prevKeyNum == seqnum || dist < 16.0 )
            bIsMoving = false;
        else lastTime = Level.TimeSeconds;
    }
}
