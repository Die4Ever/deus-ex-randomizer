class DXRMission15 injects Mission15;

function Timer()
{
    Super.Timer();

    // fix bob page exploding
    if (localURL == "15_AREA51_PAGE")
    {
        if(flags.GetBool('endgame_page')) {
            if(page == None) {
                foreach AllActors(class'#var(prefix)BobPageAugmented', page) { break; }
            }
            PageExplosionEffects();
        }
    }
}

defaultproperties
{
    spawnData(0)=(SpawnTag=UC_spawn1,SpawnClass=Class'DeusEx.SpiderBot2',Tag=spbot1,OrderTag=spiderbot1_0,lastKilledTime=-1.000000)
    spawnData(1)=(SpawnTag=dummy)
    spawnData(2)=(SpawnTag=UC_spawn2,SpawnClass=Class'DeusEx.Gray',Tag=gray_1,OrderTag=gray1_0,lastKilledTime=-1.000000)
    spawnData(3)=(SpawnTag=UC_spawn2,SpawnClass=Class'DeusEx.Gray',Tag=gray_2,OrderTag=gray2_0,lastKilledTime=-1.000000)
    spawnData(4)=(SpawnTag=dummy)
    spawnData(5)=(SpawnTag=UC_spawn3,SpawnClass=Class'DeusEx.Karkian',Tag=karkian_1,OrderTag=karkian1_0,lastKilledTime=-1.000000)
    spawnData(6)=(SpawnTag=dummy)
    spawnData(7)=(SpawnTag=dummy)
    spawnData(8)=(SpawnTag=UC_spawn3,SpawnClass=Class'DeusEx.Greasel',Tag=greasel_1,OrderTag=greasel1_0,lastKilledTime=-1.000000)
    spawnData(9)=(SpawnTag=dummy)
    spawnData(10)=(SpawnTag=dummy)
    spawnData(11)=(SpawnTag=dummy)
}
