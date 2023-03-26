class PurgeGas extends TearGas;

// copied from vanilla class Cloud, but call our own HitActor function
function Timer()
{
    local Actor A;
    local Vector dist;
    local Pawn apawn;

    if ( Level.NetMode != NM_Standalone )
    {
        // Use PawnList for multiplayer
        apawn = Level.PawnList;
        while ( apawn != None )
        {
            dist = apawn.Location - Location;
            if ( VSize(dist) < cloudRadius )
                HitActor(apawn);
            apawn = apawn.nextPawn;
        }
    }
    else
    {
        // check to see if anything has entered our effect radius
        // don't damage our owner
        foreach VisibleActors(class'Actor', A, cloudRadius)
            if (A != Owner)
                HitActor(a);
    }
}

// hack to force guys to rub their eyes even in idle states
function HitActor(Actor a)
{
    a.TakeDamage(Damage, Instigator, a.Location, vect(0,0,0), damageType);
    if( class'DXRActorsBase'.static.IsHuman(a.class)) {
        switch(a.GetStateName()) {
        case 'Dying':
        case 'RubbingEyes':
        case 'Stunned':
            break;
        default:
            #var(prefix)ScriptedPawn(a).GotoDisabledState(damageType, HITLOC_TorsoFront);
        }
    }
}

defaultproperties
{
     cloudRadius=100
     DamageType=TearGas
     maxDrawScale=7
     Damage=1
     damageInterval=0.5
     CollisionRadius=2
     CollisionHeight=2
}
