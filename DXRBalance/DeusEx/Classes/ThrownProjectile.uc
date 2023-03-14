class DXRThrownProjectile shims ThrownProjectile;

// scale trigger time with skill
simulated function Tick(float deltaTime)
{
    local float oldSkillTime;
    local #var(PlayerPawn) player;

    oldSkillTime = skillTime;
    Super.Tick(deltaTime);
    player = #var(PlayerPawn)(Owner);
    if(oldSkillTime == 0 && skillTime == 1 && player != None) {
        skillTime = player.SkillSystem.GetSkillLevelValue(class'SkillDemolition');
        skillTime = 0.5 * skillTime + 1.1;
        Player.ClientMessage(self$" skillTime: "$skillTime);
        skillTime = FClamp(skillTime, 0.75, 1.25);
    }
}

// scale arming time with skill
simulated function PreBeginPlay()
{
    local #var(PlayerPawn) player;
    local float f;

    Super.PreBeginPlay();
    player = #var(PlayerPawn)(Owner);
    if(player != None) {
        fuseLength += 4.0 * player.SkillSystem.GetSkillLevelValue(class'SkillDemolition');
        Player.ClientMessage(self$" fuseLength: "$fuseLength);
        fuseLength = FClamp(fuseLength, 0.2, 5);
    }
}

// this allows us to override GetSpawnCloudType in subclasses, in vanilla it's hardcoded to TearGas
//
// SpawnTearGas needs to happen on the server so the clouds are insync and damage is dealt out of them
//
function SpawnTearGas()
{
    local int i;
    local class<Cloud> GasType;
    local Name tDamageType;

    if ( Role < ROLE_Authority )
        return;

    for (i=0; i<blastRadius/36; i++)
    {
        if (FRand() < 0.9)
        {
            GetSpawnCloudType( GasType, tDamageType );
            SpawnCloud(GasType, tDamageType);
        }
    }
}

function GetSpawnCloudType(out class<Cloud> GasType, out Name tDamageType)
{
    GasType = class'TearGas';
    tDamageType = 'TearGas';
}

function SpawnCloud(class<Cloud> type, Name DamageType)
{
    local Vector loc;
    local Cloud gas;

    loc = Location;
    loc.X += FRand() * blastRadius - blastRadius * 0.5;
    loc.Y += FRand() * blastRadius - blastRadius * 0.5;
    loc.Z += 32;
    gas = spawn(type, None,, loc);
    if (gas == None) return;

    gas.DamageType = DamageType;
    gas.Velocity = vect(0,0,0);
    gas.Acceleration = vect(0,0,0);
    gas.DrawScale = FRand() * 0.5 + 2.0;
    gas.LifeSpan = FRand() * 10 + 30;
    if ( Level.NetMode != NM_Standalone )
        gas.bFloating = False;
    else
        gas.bFloating = True;
    gas.Instigator = Instigator;
}
