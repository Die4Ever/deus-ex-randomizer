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

function BeginPlay()
{
    if(!class'DXRFlags'.default.bZeroRandoPure) {
        spawnData[1].SpawnTag = 'dummy';
        spawnData[4].SpawnTag = 'dummy';
        spawnData[6].SpawnTag = 'dummy';
        spawnData[7].SpawnTag = 'dummy';
        spawnData[9].SpawnTag = 'dummy';
        spawnData[10].SpawnTag = 'dummy';
        spawnData[11].SpawnTag = 'dummy';
    }
    Super.BeginPlay();
}
