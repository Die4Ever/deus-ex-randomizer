class BalanceShuriken injects Shuriken;

var float blood_mult;

function SpawnBlood(Vector HitLocation, Vector HitNormal)
{
    Super.SpawnBlood(HitLocation, HitNormal);
    class'WeaponShuriken'.static.SpawnExtraBlood(Self, HitLocation, HitNormal, blood_mult);
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
        Super.HitWall(HitNormal, Wall);
        SetCollisionSize(16, 16);
    }
}

function BeginPlay()
{
    if(class'MenuChoice_BalanceItems'.static.IsEnabled()) {
        MaxSpeed = 75000;
        AccurateRange = 1920;
        maxRange = 3840;
    } else {
        MaxSpeed = 750;
        AccurateRange = 640;
        maxRange = 1280;
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
