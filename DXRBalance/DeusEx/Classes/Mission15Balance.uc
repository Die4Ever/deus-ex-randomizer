class DXRMission15 injects Mission15;

simulated function BeginPlay()
{
    local int i;

    Super.BeginPlay();

    // clear all spawners
    for(i=0; i<ArrayCount(spawnData); i++) {
        spawnData[i].spawnTag = '';
    }

    // put some back
    spawnData[0].spawnTag='UC_spawn1';
    spawnData[2].spawnTag='UC_spawn2';
    spawnData[3].spawnTag='UC_spawn2';

    spawnData[5].spawnTag='UC_spawn3';
    spawnData[8].spawnTag='UC_spawn3';
}
