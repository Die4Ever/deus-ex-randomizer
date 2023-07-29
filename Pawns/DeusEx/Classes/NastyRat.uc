//=============================================================================
// NastyRat.
//
// This is (at least for now) intended to only be spawned as a Crowd Control
// effect (simulated or real).
//=============================================================================
class NastyRat extends Rat;

var float CheckTime;
var float NextThrowTime;

var float ThrowFrequency;
var float CheckFrequency;

function Tick(float deltaSeconds)
{
    local Vector HitNormal, HitLocation, ThrowPoint;
    local #var(PlayerPawn) player;
    local #var(prefix)Cat cat;
    local Actor closestTarget;
    local float closestDistance;
    local bool closer;
    local float distance;

    local Rotator Aim;

    time+=deltaSeconds;

    if (time >1.0)
    {
        time = 0;
        if (FRand() < 0.05){
            PlaySound(sound'RatSqueak2', SLOT_None,,,,RandomPitch());
        }
    }

    if (CheckTime < Level.TimeSeconds) {
        if (CheckTime == 0.0) {
            //Don't throw a grenade the moment we spawn...
            NextThrowTime = Level.TimeSeconds + ThrowFrequency;
        }

        CheckTime = Level.TimeSeconds + CheckFrequency;

        if (NextThrowTime > Level.TimeSeconds){
            return;
        }

        closestDistance=999999;
        closestTarget=None;

        foreach AllActors(class'#var(PlayerPawn)',player){
            closer=False;
            distance = VSize(player.Location - Location);

            if (closestTarget==None || distance < closestDistance){
                if (Trace(HitLocation,HitNormal,player.Location,Location,True)==player){
                    closestTarget = player;
                    closestDistance = distance;
                }
            }
        }

        foreach AllActors(class'#var(prefix)Cat',cat){
            closer=False;
            distance = VSize(cat.Location - Location);

            if (closestTarget==None || distance < closestDistance){
                if (Trace(HitLocation,HitNormal,cat.Location,Location,True)==cat){
                    closestTarget = cat;
                    closestDistance = distance;
                }
            }
        }

        //If the rat is close...
        if (closestDistance<1000){
            //... and it has line of sight
            ThrowPoint = Location + vect(0,0,20);
            Aim = rotator(closestTarget.Location - ThrowPoint);
            Spawn(PickAGrenade(closestTarget),self,,ThrowPoint,Aim);
            NextThrowTime = Level.TimeSeconds + ThrowFrequency;
        }
    }
}

function class<Projectile> PickAGrenade(Actor closestTarget)
{
    local int i;

    //LAMs at anything that isn't a player...
    if (!closestTarget.IsA('#var(PlayerPawn)')){
        return class'#var(prefix)LAM';
    }

    i = rand(4);
    switch(i){
        case 0:
            return class'#var(prefix)LAM';
        case 1:
            return class'#var(prefix)GasGrenade';
        case 2:
            return class'#var(prefix)EMPGrenade';
        case 3:
            return class'#var(prefix)NanoVirusGrenade';
    }
    log("ERROR:  NastyRat somehow didn't pick a valid grenade!  Rolled "$i);
    return class'GasGrenade';
}

function bool ShouldBeStartled(Pawn startler)
{
    return False;
}

function float RandomPitch()
{
	return (0.25 - 0.2*FRand());
}

function float ModifyDamage(int Damage, Pawn instigatedBy, Vector hitLocation, Vector offset, Name damageType){
    if (instigatedBy==self && damageType=='Exploded'){
        Damage = Damage * 0.1;
        instigatedBy = None; //Prevents the 10x damage mult for point-blank hits
    }
    return Super.ModifyDamage(Damage,instigatedBy,hitlocation,offset,damageType);
}

defaultproperties
{
     CheckTime=0.00000
     NextThrowTime=0.0000
     ThrowFrequency=6.0
     CheckFrequency=2.0
     CollisionRadius=20.000000
     CollisionHeight=17.50000
     DrawScale=4.000000
     MinHealth=0
     HealthHead=150
     HealthTorso=150
     HealthLegLeft=150
     HealthLegRight=150
     HealthArmLeft=150
     HealthArmRight=150
     Health=150
     bFleeBigPawns=False
     bBlockActors=True
     bForceStasis=False
     Restlessness=1.00000
     Wanderlust=1.00000
     Orders=Shadowing
     MaxStepHeight=25.00000
     BaseEyeHeight=3.000000
     JumpZ=30.000000
     WalkingSpeed=1.0
     GroundSpeed=100.000000
     WaterSpeed=24.000000
     AirSpeed=60.000000
     Mass=30.000
     BindName="NastyRat"
     FamiliarName="Nasty Rat"
     UnfamiliarName="Nasty Rat"
     AttitudeToPlayer=ATTITUDE_Follow
}
