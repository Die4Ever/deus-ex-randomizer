class BalanceShuriken injects Shuriken;

function SpawnBlood(Vector HitLocation, Vector HitNormal)
{
    local Actor a;
    local vector v;
    local float mult;
    local int i;

    if ((DeusExMPGame(Level.Game) != None) && (!DeusExMPGame(Level.Game).bSpawnEffects))
        return;

    mult = Damage / default.Damage * 4;
    mult = Loge(mult) / Loge(4);
    for (i=0; i < int(mult*5.0); i++)
    {
        v = VRand()*8.0*mult;
        a = spawn(class'BloodSpurt',,,HitLocation+HitNormal+v);
        a.DrawScale *= mult;
        a = spawn(class'BloodDrop',,,HitLocation+HitNormal*4+v);
        a.DrawScale *= mult;
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
