class BalanceShuriken injects Shuriken;

var float blood_mult, rot_per_sec;
var int rotAmount;

function SpawnBlood(Vector HitLocation, Vector HitNormal)
{
    Super.SpawnBlood(HitLocation, HitNormal);
    class'WeaponShuriken'.static.SpawnExtraBlood(Self, HitLocation, HitNormal, blood_mult);
}

simulated function Tick(float deltaTime)
{
    local Rotator rot;

    if (bStuck)
        return;

    Super(DeusExProjectile).Tick(deltaTime);
    if (Level.Netmode != NM_DedicatedServer)
    {
        //DeusExProjectile tick resets the rotation every time, so we need to track the rotation
        rotAmount+=deltaTime*65536*rot_per_sec;
        rotAmount=rotAmount % 65536;
        rot = Rotation;
        rot.Roll += 16384; //To get it aligned the right direction
        rot.Pitch -= 16384; //To get it aligned the right direction
        rot.Pitch -= rotAmount; //to actually do the end over end rotation
        SetRotation(rot);
    }
}

auto simulated state Flying
{
    simulated function ProcessTouch(Actor Other, Vector HitLocation)
    {
        local DeusExPlayer player;

        Super.ProcessTouch(Other, HitLocation);

        if( ! bStuck ) return;
        player = DeusExPlayer(Other);
        if( player == None ) return;
        if( ! class'DXRActorsBase'.static.HasItem(player, spawnWeaponClass) ) return;
        player.FrobTarget = Self;
        player.ParseRightClick();
    }

    simulated function HitWall(vector HitNormal, actor Wall)
    {
        local Rotator rot;

        //Only hit the wall once
        if (!bStuck){
            //Undo any spin before actually hitting the wall
            //This makes it so it's actually stuck in the wall
            //in the right direction
            rot = Rotation;
            rot.Pitch += rotAmount;
            SetRotation(rot);

            Super.HitWall(HitNormal, Wall);
        }
        SetCollisionSize(16, 16);
    }
}

function BeginPlay()
{
    if(class'MenuChoice_BalanceItems'.static.IsEnabled()) {
        MaxSpeed = 75000;
        AccurateRange = 1920;
        maxRange = 3840;

        //According to this paper: http://www.knifethrower.com/speed.pdf
        //the average throwing knife spins 5.46 revolutions per second.
        //Randomize speed between 5 and 6 revolutions per second.
        rot_per_sec = 5.0 + FRand();
    } else {
        MaxSpeed = 750;
        AccurateRange = 640;
        maxRange = 1280;
        rot_per_sec=0; //Don't spin
    }
    Super.BeginPlay();
}

defaultproperties
{
    AccurateRange=1920
    maxRange=3840
    Speed=750.000000
    MaxSpeed=75000.000000
}
