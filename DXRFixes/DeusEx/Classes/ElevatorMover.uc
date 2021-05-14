class ElevatorMover merges ElevatorMover;
// can't do injects because it uses a state

var float lastTime;

function bool EncroachingOn( actor Other )
{
    if( Inventory(Other) != None ) {
        return false;
    }
    if( EncroachDamage < 10 && #var PlayerPawn (Other) == None ) {
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

    if( MoveTime/2 < Level.TimeSeconds-lastTime )
        oldSeq = true;
    
    if ( bIsMoving && !oldSeq )
        return;

    if (KeyNum != seqnum || oldSeq)
    {
        prevKeyNum = KeyNum;
        KeyNum = seqnum;
        dist = VSize(BasePos + KeyPos[seqnum] - Location);

        GotoState('ElevatorMover', 'Next');

        if( prevKeyNum == seqnum || dist < 16.0 )
            bIsMoving = false;
        else lastTime = Level.TimeSeconds;
    }
}
