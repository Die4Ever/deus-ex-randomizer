class ElevatorMover merges ElevatorMover;
// can't do injects because it uses a state

var float lastTime;
var float moveSpeed, originalMoveTime;

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
    local float maxDist, avgDist, distSum, dist;
    local int i, j;

    if (moveSpeed == 0.0) {
        for (i = 0; i < ArrayCount(KeyPos); i++) {
            if (i > 0 && KeyPos[i] == vect(0.0, 0.0, 0.0)) break;

            for (j = i + 1; j < ArrayCount(KeyPos); j++) {
                if (KeyPos[j] == vect(0.0, 0.0, 0.0)) break;

                dist = VSize(KeyPos[i] - KeyPos[j]);
                maxDist = FMax(maxDist, dist);
                distSum += dist;
            }
        }

        avgDist = distSum / (i * (i - 1) / 2.0);
        moveSpeed = (maxDist*0.33 + avgDist*0.67) / MoveTime;
        originalMoveTime = MoveTime;
    }

    return moveSpeed;
}

function SetSeq(int seqnum)
{
    local bool oldSeq;
    local int prevKeyNum;
    local float dist;

    if ( bIsMoving && !oldSeq )
        return;

    if( MoveTime/2 < Level.TimeSeconds-lastTime )
        oldSeq = true;

    dist = VSize(BasePos + KeyPos[seqnum] - Location);

    if (KeyPos[2] != vect(0.0, 0.0, 0.0)) {
        MoveTime = FMax(dist / GetMoveSpeed(), originalMoveTime / 2.5);
    }

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
