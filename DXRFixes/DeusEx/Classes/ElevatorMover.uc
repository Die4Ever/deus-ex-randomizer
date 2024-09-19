class ElevatorMover merges ElevatorMover;
// can't do injects because it uses a state

var float lastTime, moveSpeed, originalMoveTime;
var int numKeyPos;
var bool initialized;

function Initialize()
{
    local SequenceTrigger st;
    local float dist, maxDist, avgDist, distSum;
    local int validKeyPos[8];
    local int i, j;

    if (initialized) return;

    // calculate numKeyPos and make a list of valid KeyPos indices
    foreach AllActors(class'SequenceTrigger', st) {
        if (st.event != tag) continue;

        // check if st.seqnum is already in the list
        for (i = 0; i < numKeyPos; i++) {
            if (validKeyPos[i] == st.seqnum) {
                break;
            }
        }
        // if not, add it and increment numKeyPos
        if (i == numKeyPos) {
            validKeyPos[numKeyPos++] = st.seqnum;
        }
    }

    // do calculations using only valid KeyPos elements
    for (i = 0; i < numKeyPos; i++) {
        for (j = i + 1; j < numKeyPos; j++) {
            dist = VSize(KeyPos[validKeyPos[i]] - KeyPos[validKeyPos[j]]);
            maxDist = FMax(maxDist, dist);
            distSum += dist;
        }
    }

    avgDist = distSum / (numKeyPos * (numKeyPos - 1) / 2.0);
    moveSpeed = (maxDist*0.33 + avgDist*0.67) / MoveTime;
    originalMoveTime = MoveTime;

    initialized = true;
}

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

function SetSeq(int seqnum)
{
    local bool oldSeq;
    local int prevKeyNum;
    local float dist;

    Initialize();

    if( MoveTime/10 < Level.TimeSeconds-lastTime )
        oldSeq = true;

    if ( bIsMoving && !oldSeq )
        return;

    dist = VSize(BasePos + KeyPos[seqnum] - Location);

    if (numKeyPos > 2)
        MoveTime = FMax(dist / moveSpeed, originalMoveTime / 2.5);

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
