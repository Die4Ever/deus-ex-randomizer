class ThrownProjectile shims ThrownProjectile;

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
            SpawnCloudType( GasType, tDamageType );
            SpawnCloud(GasType, tDamageType);
        }
    }
}

function SpawnCloudType(out class<Cloud> GasType, out Name tDamageType)
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
