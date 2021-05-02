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

defaultproperties
{
    AccurateRange=2000
    maxRange=4000
    Speed=750.000000
    MaxSpeed=75000.000000
}
