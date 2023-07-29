//=============================================================================
// NastyRat.
//
// This is (at least for now) intended to only be spawned as a Crowd Control
// effect (simulated or real).
//=============================================================================
class NastyRat extends Rat;

var float CheckTime;
var float NextThrowTime;

function Tick(float deltaSeconds)
{
    local Vector HitNormal, HitLocation, ThrowPoint;
    local #var(PlayerPawn) player;
    local Rotator Aim;

    if (CheckTime < Level.TimeSeconds) {

        CheckTime = Level.TimeSeconds + 2;

        if (NextThrowTime > Level.TimeSeconds){
            return;
        }

        foreach AllActors(class'#var(PlayerPawn)',player){break;}
        if (player==None){
            return;
        }

        //If the rat is close...
        if (VSize(player.Location - Location)<1000){
            if (Trace(HitLocation,HitNormal,player.Location,Location,True)==player){
                //... and it has line of sight
                ThrowPoint = Location + vect(0,0,20);
                Aim = rotator(player.Location - ThrowPoint);
                Spawn(PickAGrenade(),,,ThrowPoint,Aim);
                NextThrowTime = Level.TimeSeconds + 6;
            }

        }
    }
}

function class<Projectile> PickAGrenade()
{
    local int i;

    i = rand(4);

    switch(i){
        case 0:
            return class'LAM';
        case 1:
            return class'GasGrenade';
        case 2:
            return class'EMPGrenade';
        case 3:
            return class'NanoVirusGrenade';
    }
    log("ERROR:  NastyRat somehow didn't pick a valid grenade!  Rolled "$i);
    return class'GasGrenade';
}

//The rat won't be holding a weapon, so just fake it out
function bool IsThrownWeapon(DeusExWeapon testWeapon)
{
	return True;
}

function bool ShouldBeStartled(Pawn startler)
{
    return False;
}

defaultproperties
{
     CheckTime=0.00000
     NextThrowTime=0.0000
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
     Orders=Following
     MaxStepHeight=25.00000
     BaseEyeHeight=3.000000
     JumpZ=30.000000
     WalkingSpeed=0.18
     GroundSpeed=100.000000
     WaterSpeed=24.000000
     AirSpeed=60.000000
     Mass=30.000
     BindName="NastyRat"
     FamiliarName="Nasty Rat"
     UnfamiliarName="Nasty Rat"
}
