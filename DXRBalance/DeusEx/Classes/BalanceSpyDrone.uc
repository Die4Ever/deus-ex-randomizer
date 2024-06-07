class BalanceSpyDrone injects SpyDrone;

simulated function MoveDrone( float DeltaTime, Vector loc )
{
    DeltaTime = FClamp(DeltaTime, 0.0001, 0.5);
    // DXRando: moved out of the player class, make it a little easier to maneuver
    // if the wanted velocity is zero, apply drag so we slow down gradually
    if (VSize(loc) == 0)
    {
        // DXRando: make this somewhat framerate independent, it's not perfect
        Velocity *= 1.0 - DeltaTime*5.0;
    }
    else
    {
        //Velocity += deltaTime * MaxSpeed * loc;
        Velocity = MaxSpeed * loc;
    }

    // add slight bobbing
    // DEUS_EX AMSD Only do the bobbing in singleplayer, we want stationary drones stationary.
    //if (Level.Netmode == NM_Standalone)
        //Velocity += deltaTime * Sin(Level.TimeSeconds * 2.0) * vect(0,0,1);
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name damageType)
{
    Super.TakeDamage(Damage, instigatedBy, HitLocation, Momentum, damageType);

    //Decrease the despawn time of the drone so that it is gone by the time you can reactivate the aug
    //(Since we reduced that timer as well).
    //This fixes an issue where reactivating the aug before the old drone has despawn gives you the camera
    //from the old drone instead, while controlling the new one.
    if (LifeSpan==10.0 && class'AugDrone'.Default.reconstructTime < 10.0){
        LifeSpan=class'AugDrone'.Default.reconstructTime-0.1;
    }
}

function Destroyed()
{
    if ( DeusExPlayer(Owner) != None ) {
        DeusExPlayer(Owner).aDrone = None;
        DeusExPlayer(Owner).DroneExplode();
    }

    Super.Destroyed();
}
