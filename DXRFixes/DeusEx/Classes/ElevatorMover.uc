class ElevatorMover merges ElevatorMover;
// can't do injects because it uses a state

var float lastTime;

function bool EncroachingOn( actor Other )
{
    if( Inventory(Other) != None ) {
        return false;
    }
    if( #var PlayerPawn (Other) == None ) {
        Other.TakeDamage( 10000, Instigator, Other.Location, vect(0,0,0), 'Crushed' );
        return false;
    }
    Super.EncroachingOn(Other);
    return false;
}

function SetSeq(int seqnum)
{
    local bool oldSeq;
    if( MoveTime/2 < Level.TimeSeconds-lastTime )
        oldSeq = true;
    
    if ( bIsMoving && !oldSeq )
        return;
    
    lastTime = Level.TimeSeconds;

    if (KeyNum != seqnum || oldSeq)
    {
        KeyNum = seqnum;
        GotoState('ElevatorMover', 'Next');
    }
}
